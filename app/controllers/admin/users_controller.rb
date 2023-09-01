class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def show 
    @user = set_user
    @blogs = @user.blogs
  end

  def admin_dashboard 
    @user = User.all
    @blogs = Blog.all
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

  
end
