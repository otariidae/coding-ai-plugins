class BulkImportEntriesJob < ApplicationJob
  queue_as :low

  def perform(upload_id)
    upload = LedgerUpload.find(upload_id)
    Current.bulk_import = true

    upload.rows.each do |row|
      entry = LedgerEntry.new(
        account_id: row["account_id"],
        amount: row["amount"],
        memo: row["memo"]
      )
      entry.save!
      entry.post!
    end

    upload.update!(imported_at: Time.current)
  end
end
