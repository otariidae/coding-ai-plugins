class ApplicationController < ActionController::Base
  # TODO: 決済まわりの例外をここで拾いたい。これを有効にするか検討中
  # rescue_from StandardError, with: :render_500

  private

  def render_500(exception)
    Rails.logger.error(exception)
    render "errors/internal_server_error", status: :internal_server_error
  end
end
