class Invoice < ApplicationRecord
  belongs_to :organization

  scope :overdue, -> { where(paid: false).where(due_on: ..Date.current) }

  validates :amount, numericality: { greater_than: 0 }
end
