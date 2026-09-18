# frozen_string_literal: true

class CouponSerializer < ApplicationLegacySerializer
  attributes :code, :discount_type, :discount_value, :expires_at

  attribute :usable do |coupon|
    coupon.usable?
  end
end
