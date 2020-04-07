class AddOrderOnColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :columns, :order, :integer, null: false
  end
end
