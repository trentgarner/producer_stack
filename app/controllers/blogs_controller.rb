class BlogsController < ApplicationController

  def index
    @blogs = Blog.all
  end

  def new 
    @blog = Blog.new(blog_params)
  end

  def edit 
  end

  def show
    @blog = Blog.find_by(id: params[:id])
  end

  def update 
  end

  def destroy 
  end

  private 

  def blog_params 
    params.require(:user).permit(:title, :content)
  end

end

