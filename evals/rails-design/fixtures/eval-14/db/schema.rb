# schema.rb の抜粋（関係するテーブルのみ）
ActiveRecord::Schema[8.0].define(version: 2026_09_10_120000) do
  create_table "accounts", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "balance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_accounts_on_code", unique: true
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "created_by_id", null: false
    t.integer "amount", null: false
    t.integer "fiscal_year"
    t.string "memo"
    t.datetime "posted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ledger_entries_on_account_id"
  end

  create_table "ledger_uploads", force: :cascade do |t|
    t.bigint "requested_by_id", null: false
    t.jsonb "rows", default: [], null: false
    t.datetime "imported_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["requested_by_id"], name: "index_ledger_uploads_on_requested_by_id"
  end
end
