class TasksController < ApplicationController

  # 「current_user.~」はapplication_controllerで作成したcurrent_userを用いてログインユーザーの情報のみ取り出すようにしている

  # @task = current_user.tasks.find(params[:id])がshow, edit, update, destroyメソッドで繰り返し利用されている
  # これはDRY(Don't Repeat Yourself)の原則に背くのでbefore_actionのフィルタを使って各メソッドのアクション前に実行させるようにする
  before_action :set_tasks, only: [:show, :edit, :update, :destroy]

  def index
    # ransackを用いて検索機能を追加する
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true)
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
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を削除しました。"
  end
  private

  def task_params
    params.require(:task).permit(:name, :description, :image)
  end

  def set_tasks
    @task = current_user.tasks.find(params[:id])
  end
end
