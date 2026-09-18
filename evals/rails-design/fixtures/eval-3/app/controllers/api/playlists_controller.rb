class Api::PlaylistsController < Api::ApplicationController
  before_action :set_playlist, only: %i[ show update destroy publish ]

  def index
    @playlists = Current.user.playlists.ordered
  end

  def show
  end

  def create
    @playlist = Current.user.playlists.create!(playlist_params)

    render :show, status: :created, location: api_playlist_url(@playlist)
  end

  def update
    @playlist.update! playlist_params

    render :show
  end

  def destroy
    @playlist.destroy

    head :no_content
  end

  def publish
    @playlist.publish!

    render :show
  end

  private
    def set_playlist
      @playlist = Current.user.playlists.find(params[:id])
    end

    def playlist_params
      params.expect(playlist: [ :name, :description, :visibility ])
    end
end
