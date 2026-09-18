class PaymentsController < ApplicationController
  def create
    @invoice = Invoice.find(params[:invoice_id])
    result = PaymentClient.new.charge(
      amount: @invoice.amount,
      customer_token: @invoice.customer.payment_token
    )
    @invoice.update!(paid: true, external_charge_id: result["id"])
    redirect_to @invoice, notice: "お支払いを受け付けました"
  end
end
