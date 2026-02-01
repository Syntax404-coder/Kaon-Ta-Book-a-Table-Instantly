class AddIsClosedToTables < ActiveRecord::Migration[8.1]
  def change
    add_column :tables, :is_closed, :boolean, default: false
  end
end
