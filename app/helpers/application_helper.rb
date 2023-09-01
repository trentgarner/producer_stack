module ApplicationHelper

  def set_background
    case params[:controller]
    when 'blogs' then 'hero-blog'
    else 'hero-home'
    end
  end

  def truncate_words(text, num_words)
    words = text.split
    truncated = words[0, num_words].join(' ')
    truncated << ' ...' if words.length > num_words
    truncated
  end
  
end
