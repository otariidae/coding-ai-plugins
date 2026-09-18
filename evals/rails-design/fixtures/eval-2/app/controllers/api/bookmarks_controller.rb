class Api::BookmarksController < Api::ApplicationController
  before_action :set_bookmark, only: %i[ update destroy ]
  before_action :ensure_owner, only: %i[ update destroy ]

  def index
    @bookmarks = Current.user.bookmarks.ordered

    respond_to do |format|
      format.json { render :index }
    end
  end

  def create
    @bookmark = Current.user.bookmarks.create!(bookmark_params)

    render json: { success: true, id: @bookmark.id }, status: :created
  end

  def update
    @bookmark.update! bookmark_params

    render json: { success: true }
  end

  def destroy
    @bookmark.destroy

    render json: {}, status: :ok
  end

  private
    def set_bookmark
      @bookmark = Bookmark.find(params[:id])
    end

    def ensure_owner
      if @bookmark.user != Current.user
        render json: { error: "You are not allowed to edit this bookmark" }, status: :forbidden
      end
    end

    def bookmark_params
      params.expect(bookmark: [ :url, :title, :note ])
    end
end
