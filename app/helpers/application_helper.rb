module ApplicationHelper

  def set_background 
    if params[:controller] == 'application' || 'sessions'
      "hero-home"
    elsif params[:controller] == 'blogs'
      "hero-blog"
    end

  end

end
