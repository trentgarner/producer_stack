class Admin::UsersController < ApplicationController

  def show 
    @user = User.find_by_id(params[:id])
  end

  def admin_dashboard 
    @user = User.all
    @blogs = Blog.all
  end
  
end
