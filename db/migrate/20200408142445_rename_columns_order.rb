class RenameColumnsOrder < ActiveRecord::Migration[6.0]
  def change
    rename_column :columns, :order, :column_order
  end
end
