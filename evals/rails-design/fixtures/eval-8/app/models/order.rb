class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, default: :pending

  accepts_nested_attributes_for :order_items

  validates :shipping_address, presence: true

  def total_amount
    order_items.sum { |item| item.unit_price * item.quantity }
  end
end
