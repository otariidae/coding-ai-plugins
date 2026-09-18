class Invoice < ApplicationRecord
  belongs_to :customer

  validates :amount, numericality: { greater_than: 0 }

  scope :unpaid, -> { where(paid: false) }

  # invoices: amount:integer, paid:boolean, external_charge_id:string
end
