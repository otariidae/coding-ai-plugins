# frozen_string_literal: true

module Web
  module Customers
    class CartsController < Web::Customers::ApplicationController
      before_action :set_cart, only: %i[show destroy]

      def index
        @carts = current_customer.carts.active.includes(items: { variation: :product })
      end

      def show
      end

      def destroy
        @cart.destroy

        render json: { status: "ok" }
      end

      private

      def set_cart
        @cart = current_customer.carts.find(params[:id])
      end
    end
  end
end
