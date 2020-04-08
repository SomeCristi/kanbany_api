class Column < ApplicationRecord
  # Model associations
  belongs_to :board
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  has_many :tasks

  # Validations

  # Validates presence of those attributes
  # For board it checks if the record exists
  validates :created_by, :name, :board, :column_order, presence: true

  validate :check_column_order

  validates :column_order, numericality: { greater_than: 0 }

  # Callbacks
  before_save :update_column_orders

  private

  # If object is created or the column_order is being changed
  # Checks if column_order is not more than the last column_order + 1
  # Example: if the last column_order on a column is 3, the next one
  # cannot be 5
  def check_column_order
    # Checks if board is present(not board id because an id that does not belong to a board can be provided)
    # in case this valdiation is run before the one that checks the presence of board
    # If board is nil the comparison inside the if failed
    if column_order_changed? && board.present?
      errors.add(:column_order, 'must be maximum last column order + 1') if self.column_order - 1 > self.board.columns.count + 1
    end
  end

  # Updates all the columns that have column order greater or equal than
  # current column order to have their old order value + 1.
  # This uses only one SQL UPDATE Statement
  # Example: If there are 3 columns with order 1, 2, 3 and we want to add one column
  # on the second position, the columns that were on position 2 and 3 will be on position 3 and 4
  def update_column_orders
    Column.where("column_order >= ?", column_order).update_all("column_order = column_order + 1")
  end
end
