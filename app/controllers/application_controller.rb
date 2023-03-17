class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def router 
    if current_user.role == "admin"
      redirect_to admin_user_path(current_user.id)
    else
      redirect_to user_path(current_user.id)
    end
  end

end
