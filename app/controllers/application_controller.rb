class ApplicationController < ActionController::Base
  # helper_method指定をすることでcurrent_userメソッドをビューからも使えるようにする
  helper_method :current_user

  # before_action指定することで全てのアクションに対してログインを求める
  before_action :login_required

  private

  # ログイン情報を取得するためのメソッド
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # ログインしていないとログインページへ飛ばすメソッド
  def login_required
    redirect_to login_url unless current_user
  end
end
