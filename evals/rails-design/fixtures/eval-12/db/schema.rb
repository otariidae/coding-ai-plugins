# schema.rb の抜粋（関係するテーブルのみ）
ActiveRecord::Schema[8.0].define(version: 2026_08_28_110000) do
  create_table "invoices", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "external_id", null: false
    t.integer "amount", null: false
    t.date "due_on", null: false
    t.boolean "paid", default: false, null: false
    t.boolean "reminder_email_sent", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_invoices_on_organization_id"
  end
end
