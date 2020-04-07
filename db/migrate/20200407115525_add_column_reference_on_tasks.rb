class AddColumnReferenceOnTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :column, index: true, null: false
  end
end
