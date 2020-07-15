class TasksController < ApplicationController

  # 「current_user.~」はapplication_controllerで作成したcurrent_userを用いてログインユーザーの情報のみ取り出すようにしている

  # @task = current_user.tasks.find(params[:id])がshow, edit, update, destroyメソッドで繰り返し利用されている
  # これはDRY(Don't Repeat Yourself)の原則に背くのでbefore_actionのフィルタを使って各メソッドのアクション前に実行させるようにする
  before_action :set_tasks, only: [:show, :edit, :update, :destroy]

  def index
    # orderメソッドでORDER BY節を生成し作成日時の新しい順に並べる
    @tasks = current_user.tasks.order(created_at: :desc)
  end

  def show
    @task = current_user.tasks.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.new(task_params)
    if @task.save
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
    params.require(:task).permit(:name, :description)
  end

  def set_tasks
    @task = current_user.tasks.find(params[:id])
  end
end
