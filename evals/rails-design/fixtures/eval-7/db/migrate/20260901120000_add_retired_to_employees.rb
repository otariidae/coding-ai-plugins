class AddRetiredToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :retired, :boolean
  end
end
