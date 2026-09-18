class PaymentClient
  ENDPOINT = "https://api.example-pay.test/v1/charges".freeze

  def initialize(api_key: Rails.application.credentials.dig(:payment, :api_key))
    @api_key = api_key
  end

  def charge(amount:, customer_token:)
    response = Faraday.post(ENDPOINT) do |req|
      req.headers["Authorization"] = "Bearer #{@api_key}"
      req.headers["Content-Type"] = "application/json"
      req.options.timeout = 5
      req.body = { amount: amount, customer_token: customer_token }.to_json
    end

    JSON.parse(response.body)
  end
end
