class ApplicationController < ActionController::Base
  # 独自エラーだけを JSON レスポンスに変換し、それ以外は握らずに再送出する。
  # 再送出することで Rails 既定の rescue_responses と Sentry 通知は
  # これまでどおり効く。ここで握りつぶすことはしない。
  rescue_from StandardError, with: :handle_generic_error

  private

  def handle_generic_error(error)
    raise error unless error.respond_to?(:to_error_response)

    render json: error.to_error_response, status: error.http_status
  end
end
