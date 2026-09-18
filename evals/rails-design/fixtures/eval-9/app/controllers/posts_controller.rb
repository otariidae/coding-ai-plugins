class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy publish unpublish toggle_featured archive]

  def index
    @posts = Post.all
  end

  def show
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      PostIndexerJob.perform_later(@post.id)
      redirect_to @post, notice: "作成しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "更新しました"
    else
      render :edit
    end
  end

  def destroy
    @post.update(deleted: true)
    redirect_to posts_path
  end

  def publish
    ActiveRecord::Base.transaction do
      @post.update!(published: true, published_at: Time.current)
      @post.user.increment!(:published_posts_count)
      NotifySubscribersService.new(@post).call
    end
    redirect_to @post, notice: "公開しました"
  rescue => e
    redirect_to @post, alert: e.message
  end

  def unpublish
    @post.update(published: false, published_at: nil)
    redirect_to @post
  end

  def toggle_featured
    @post.update(featured: !@post.featured)
    redirect_to @post
  end

  def archive
    @post.update(archived: true)
    redirect_to posts_path
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
