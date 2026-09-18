module Billing
  class Client
    BASE_URL = "https://api.billing.test/v2".freeze

    def initialize
      @conn = Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :raise_error
        f.options.timeout = 10
      end
    end

    def send_reminder(invoice_id:, template:)
      response = @conn.post("invoices/#{invoice_id}/reminders", { template: template })
      JSON.parse(response.body)
    end

    def fetch_invoice(invoice_id)
      response = @conn.get("invoices/#{invoice_id}")
      JSON.parse(response.body)
    end
  end
end
