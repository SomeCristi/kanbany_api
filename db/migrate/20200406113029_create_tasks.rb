class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.text :description
      t.belongs_to :created_by, null: false
      t.belongs_to :assigned_to
      t.integer :order, null: false

      t.timestamps
    end
  end
end
