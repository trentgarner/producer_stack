class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:home]

  def router 
    if current_user.role == "admin"
      redirect_to admin_user_path(current_user.id)
    elsif current_user.role != "admin"
      redirect_to user_path(current_user.id)
    else
      redirect_to home_path 
    end
  end

  def home 

  end

  private 

  def after_sign_out_path_for(user)
    home_path
  end


end
