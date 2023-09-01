class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]
  

  def index
    @blogs = Blog.all
  end

  def new 
    @blog = Blog.new
  end

  def create
    @blog = current_user.blogs.new(blog_params)    
    if @blog.save
      redirect_to @blog, notice: 'Blog was successfully created.'
    else
      render :new
    end
  end

  def edit 
    validate_user
  end

  def show
    @blog = Blog.find_by(id: params[:id])
  end

  def update
    if @blog.update(blog_params)
      redirect_to @blog, notice: 'Blog was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy
    redirect_to blogs_path, notice: "Blog was successfully deleted."
  end

  private 

  def blog_params 
    params.require(:blog).permit(:title, :content)
  end

  def set_blog
    @blog = Blog.find(params[:id])
  end  

  def validate_user 
    unless @blog.user == current_user
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to blogs_path
    end
  end

end

