class CreateColumns < ActiveRecord::Migration[6.0]
  def change
    create_table :columns do |t|
      t.string :name, null: false
      t.belongs_to :board, null: false
      t.belongs_to :created_by, null: false

      t.timestamps
    end
  end
end
