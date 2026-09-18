# frozen_string_literal: true

module Api
  class CouponsController < Api::ApplicationController
    before_action :set_coupon, only: %i[show destroy]

    def index
      coupons = current_shop.coupons.active

      render json: CouponSerializer.new(coupons).serializable_hash
    end

    def show
      render json: CouponSerializer.new(@coupon).serializable_hash
    end

    def create
      coupon = current_shop.coupons.create!(coupon_params)

      render json: {
        code: coupon.code,
        discount_type: coupon.discount_type,
        discount_value: coupon.discount_value,
        expires_at: coupon.expires_at,
      }, status: :created
    end

    def destroy
      @coupon.destroy

      render json: { deleted: true }
    end

    private

    def set_coupon
      @coupon = current_shop.coupons.find(params[:id])
    end

    def coupon_params
      params.expect(coupon: [:code, :discount_type, :discount_value, :expires_at])
    end
  end
end
