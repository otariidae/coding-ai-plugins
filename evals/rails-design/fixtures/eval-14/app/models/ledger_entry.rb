class LedgerEntry < ApplicationRecord
  belongs_to :account
  belongs_to :created_by, class_name: "User", default: -> { Current.user }

  after_find { Current.touch_account(account.code) }

  scope :for_current_fiscal_year, -> { where(fiscal_year: Current.fiscal_year) }

  validates :amount, numericality: { other_than: 0 }

  def self.isolation_level
    Current.bulk_import ? :read_committed : :serializable
  end

  def post!
    self.class.transaction(isolation: self.class.isolation_level) do
      update!(posted_at: Time.current, fiscal_year: Current.fiscal_year)
      account.recalculate_balance!
    end
  end
end
