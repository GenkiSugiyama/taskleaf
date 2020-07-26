class TasksController < ApplicationController

  # 「current_user.~」はapplication_controllerで作成したcurrent_userを用いてログインユーザーの情報のみ取り出すようにしている

  # @task = current_user.tasks.find(params[:id])がshow, edit, update, destroyメソッドで繰り返し利用されている
  # これはDRY(Don't Repeat Yourself)の原則に背くのでbefore_actionのフィルタを使って各メソッドのアクション前に実行させるようにする
  before_action :set_tasks, only: [:show, :edit, :update, :destroy]

  def index
    # ransackを用いて検索機能を追加する
    @q = current_user.tasks.ransack(params[:q])
    # perスコープで表示件数を指定することで1ページごとの表示件数を変更できる
    @tasks = @q.result(distinct: true).page(params[:page]).per(50)

    # indexアクション内にcsv出力機能を用意する
    respond_to do |format|
      format.html # htmlとしてアクセスされた場合はデフォルトのindex.html.slimを表示させる
      # ↓csvとしてアクセスされた場合は@tasksのデータでcsvを出力しそのデータをブラウザからダウンロードできるようにする
      format.csv { send_data @tasks.generate_csv, file_name: "tasks-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def show
    @task = current_user.tasks.find(params[:id])
  end

  def new
    @task = Task.new
  end

  # 新規登録画面→DBへの登録の間に確認画面を追加する用のアクション
  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  def create
    @task = current_user.tasks.new(task_params)

    # 確認画面で「戻る」ボタンが押されたときの処理を追加
    if params[:back].present?
      render :new
      return
    end

    if @task.save
      # task_mailer.rbで定義したcreation_emailメソッドを使ってメールを送る
      # deliver_nowは即時送信を行うためのメソッド
      TaskMailer.creation_email(@task).deliver_now

      # タスク生成時にジョブを呼び出す
      # setメソッドで実行タイミングを指定可能
      SampleJob.set(wait_until: Date.tomorrow.noon).perform_later

      redirect_to @task, notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @task.update!(task_params)
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を更新しました。"
  end

  def destroy
    @task.destroy
    # 画面処理はAjaxで行うのでサーバーサイド側で画面の再表示は不要となるのでredirect_toは削除
    # headメソッドで削除後はレスポンスボディなしでHTTPステータス204（成功）が買えるよう記述（サーバーから返されるイベントによってフロント側でJSを発火）
    # head :no_content
    # サーバー側からJSのコードを返すので↑コメントアウト
  end

  # csvインポート用のアクションを追加
  def import
    # puts params[:file]
    current_user.tasks.import(params[:file])
    redirect_to tasks_url, notice: "タスクを追加しました"
  end

  private

  def task_params
    params.require(:task).permit(:name, :description, :image)
  end

  def set_tasks
    @task = current_user.tasks.find(params[:id])
  end
end
