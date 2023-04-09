class BlogsController < ApplicationController

  def index
    @blogs = Blog.all
  end

  def create
  end

  def new 
    @blog - Blog.new
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
    
  end

end

