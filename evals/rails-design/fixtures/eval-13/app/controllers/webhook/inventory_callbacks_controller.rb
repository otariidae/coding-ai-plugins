module Webhook
  class InventoryCallbacksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      begin
        token = request.headers["X-Inventory-Signature"]
        Inventory::SignatureVerifier.verify!(token, request.raw_post)
      rescue Inventory::SignatureVerifier::VerificationError => e
        raise "signature verification failed: #{e.message}"
      end

      payload = JSON.parse(request.raw_post)
      loan = EquipmentLoan.find_by!(external_code: payload["loan_code"])
      loan.update!(status: payload["status"])

      head :no_content
    rescue => e
      Rails.logger.error("inventory callback error: #{e.message}")
      head :no_content
    end
  end
end
