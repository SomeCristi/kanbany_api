class RenameTaskOrder < ActiveRecord::Migration[6.0]
  def change
    rename_column :tasks, :order, :task_order
  end
end
