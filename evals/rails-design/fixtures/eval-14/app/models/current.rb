class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :request_id

  # 締め処理で選択中の会計年度
  attribute :fiscal_year

  # 一括取り込み中かどうか
  attribute :bulk_import

  # そのリクエストで触れた勘定科目コードを貯めていく（監査ログ用）
  attribute :touched_account_codes

  def touch_account(code)
    self.touched_account_codes ||= []
    self.touched_account_codes << code
  end
end
