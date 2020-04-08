class CreateMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :memberships do |t|
      t.belongs_to :board_id, null: false
      t.belongs_to :user_id, null: false

      t.timestamps
    end
  end
end
