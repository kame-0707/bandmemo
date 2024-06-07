class UsersController < ApplicationController
  skip_before_action :require_login, only: %i[new create]
  def new
    @user = User.new
  end

  def create
    Rails.logger.debug(params.inspect)
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: 'ユーザー登録が完了しました'
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end