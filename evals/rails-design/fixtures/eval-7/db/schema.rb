# このファイルは schema.rb の抜粋です（関係するテーブルのみ）
ActiveRecord::Schema[8.0].define(version: 2026_08_20_100000) do
  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.string "employee_code", null: false
    t.string "last_name", null: false
    t.string "first_name", null: false
    t.date "hired_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "worked_on", null: false
    t.datetime "clocked_in_at"
    t.datetime "clocked_out_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "worked_on"], name: "index_attendances_on_employee_id_and_worked_on", unique: true
  end
end
