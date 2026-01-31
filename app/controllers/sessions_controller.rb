class SessionsController < ApplicationController
  before_action only: [:new] do
    redirect_to root_path if current_user
  end

  after_action :set_return_path, only: [:new]

  def new
  end

  def create
    @user = User.find_by_username(params[:username])

    if @user.present? && @user.authenticate(params[:password])
      return_path = session[:return_to]
      reset_session

      session[:user_id] = @user.id
      session[:return_to] = return_path

      refresh_remember_token_cookie if params[:remember_me].present? && params[:remember_me] != "0"

      redirect_to(session[:return_to] || root_path, fallback_location: root_path)
    else
      flash[:alert] = "Username or password is invalid"
      redirect_to login_path
    end
  end

  def destroy
    current_user.remember_tokens.destroy_all if current_user&.remember_tokens.any?

    destroy_remember_token_cookie
    reset_session

    redirect_to login_path
  end

  private

  def set_return_path
    return unless request.referrer.present?

    referrer_domain = URI(request.referrer).host
    current_domain = request.host

    session[:return_to] = request.referrer if referrer_domain == current_domain
  end
end
