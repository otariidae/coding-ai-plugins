class Account < ApplicationRecord
  has_many :ledger_entries, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true

  def recalculate_balance!
    update!(balance: ledger_entries.for_current_fiscal_year.sum(:amount))
  end
end
