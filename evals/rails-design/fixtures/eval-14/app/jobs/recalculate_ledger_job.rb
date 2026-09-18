class RecalculateLedgerJob < ApplicationJob
  queue_as :default

  def perform(account_id)
    account = Account.find(account_id)
    account.recalculate_balance!
  end
end
