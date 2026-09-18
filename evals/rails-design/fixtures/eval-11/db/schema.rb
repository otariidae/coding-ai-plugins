# schema.rb の抜粋（関係するテーブルのみ）
ActiveRecord::Schema[8.0].define(version: 2026_09_01_090000) do
  create_table "expense_reports", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "title", null: false
    t.integer "amount", null: false
    t.date "spent_on", null: false

    t.boolean "approved", default: false, null: false
    t.datetime "approved_at"
    t.datetime "rejected_at"

    # 申請者が「監査対象にするか」を自己申告する欄。
    # NULL = まだ申告していない（申請途中で保存した状態）を表す三値で、
    # false（対象外と申告した）とは区別する必要があるため default を置かない。
    t.boolean "requires_audit"

    # 経理側で下書き表示するかどうか。default / null 指定なし
    t.boolean "visible_in_draft_list"

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_expense_reports_on_employee_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "expense_report_id", null: false
    t.integer "kind", null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
