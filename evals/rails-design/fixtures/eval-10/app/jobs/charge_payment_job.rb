class ChargePaymentJob < ApplicationJob
  queue_as :default

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    result = PaymentClient.new.charge(
      amount: invoice.amount,
      customer_token: invoice.customer.payment_token
    )
    invoice.update!(paid: true, external_charge_id: result["id"])
  rescue => e
    Rails.logger.warn("charge failed for invoice=#{invoice_id}: #{e.message}")
    retry_job wait: 30.seconds
  end
end
