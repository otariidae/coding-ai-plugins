class ExpenseReport < ApplicationRecord
  belongs_to :employee
  has_many :audit_logs, dependent: :destroy

  validates :title, :amount, :spent_on, presence: true
  validates :amount, numericality: { greater_than: 0 }

  scope :approved, -> { where(approved: true) }

  def approved?
    approved && approved_at.present?
  end
end
