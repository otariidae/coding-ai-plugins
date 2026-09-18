class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      redirect_to @order
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @order = Order.find(params[:id])
    OrderConfirmationService.new(@order).call
    redirect_to @order, notice: "注文を確定しました"
  end

  private

  def order_params
    params.require(:order).permit(:shipping_address, order_items_attributes: %i[product_id quantity])
  end
end
