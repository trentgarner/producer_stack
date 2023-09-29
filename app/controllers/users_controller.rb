class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user, flash: { notice: 'User was successfully updated.' }
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, flash: { notice: 'User was successfully destroyed.' }
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find_by_id(params[:id])
    redirect_to users_url, alert: 'User not found' if @user.nil?
  end
end
