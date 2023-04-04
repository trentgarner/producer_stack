module ApplicationHelper

  def set_background
    case params[:controller]
    when 'application', 'sessions' then 'hero-home'
    when 'blogs' then 'hero-blog'
    end
  end
  
end
