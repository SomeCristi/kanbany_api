class CreateBoards < ActiveRecord::Migration[6.0]
  def change
    create_table :boards do |t|
      t.string :name, null: false
      t.belongs_to :created_by, null: false

      t.timestamps
    end
  end
end
