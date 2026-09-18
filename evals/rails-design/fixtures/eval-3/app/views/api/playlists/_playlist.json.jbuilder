json.cache! playlist do
  json.(playlist, :id, :name, :description, :visibility)
  json.published playlist.published?
  json.created_at playlist.created_at.utc
  json.url api_playlist_url(playlist)
  json.owner playlist.owner, partial: "api/users/user", as: :user
end
