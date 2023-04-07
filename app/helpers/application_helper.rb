module ApplicationHelper

  def set_background
    case params[:controller]
    when 'blogs' then 'hero-blog'
    else 'hero-home'
    end
  end
  
end
