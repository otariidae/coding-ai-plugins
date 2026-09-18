# 書きかけ。ここに注文確定の処理をまとめるつもり。
class OrderConfirmationService
  def initialize(order)
    @order = order
  end

  def call
    ActiveRecord::Base.transaction do
      decrement_stock
      charge
      send_confirmation_email
      @order.confirmed!
    end
  end

  private

  def decrement_stock
    @order.order_items.each do |item|
      item.product.decrement!(:stock_quantity, item.quantity)
    end
  end

  def charge
    Stripe::Charge.create(
      amount: @order.total_amount.to_i,
      currency: "jpy",
      source: @order.customer.stripe_token
    )
  end

  def send_confirmation_email
    OrderMailer.confirmation(@order).deliver_now
  end
end
