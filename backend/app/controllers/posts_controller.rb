class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  def index
    user = User.find_by_name params[:user_name]
    sub = Sub.find_by_name params[:sub_name]
    posts = (user || sub).posts

    render json: PostSerializer.new(posts)
  end

  def show
    render json: PostSerializer.new(@post)
  end

  def create
    post = Post.new(post_params)
    user = User.find_by_name(params[:user_name]) || User.find(post_params[:user_id])
    sub = Sub.find_by_name(params[:sub_name]) || Sub.find(post_params[:sub_id])

    post.assign_attributes user_id: user.id, sub_id: sub.id

    if post.save
      render json: PostSerializer.new(post), status: :created
    else
      render json: post.errors, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: PostSerializer.new(@post)
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

  def post_params
    params.require(:post).permit(:user_id, :sub_id, :title, :url, :body)
  end
end
