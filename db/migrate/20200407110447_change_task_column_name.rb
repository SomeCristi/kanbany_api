class ChangeTaskColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :tasks, :name, :title
  end
end
