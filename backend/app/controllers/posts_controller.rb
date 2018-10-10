class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]
  before_action :set_user, only: [:update, :destroy]
  before_action :set_sub, only: [:update, :destroy]

  def index
    @posts = Post.all

    render json: @posts
  end

  def show
    render json: @post
  end

  def create
    create_params = post_params
    byebug
    create_params[:user_id] = User.find_by_name!(create_params.delete(:user_name))
    create_params[:sub_id] = Sub.find_by_name!(create_params.delete(:sub_name))
    @post = Post.new(create_params)

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def set_user
    @user = User.find_by_name!(post_params[:user_name])
  end

  def set_sub
    @sub = Sub.find_by_name!(post_params[:sub_name])
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:user_name, :sub_name, :title, :url, :body)
  end
end
