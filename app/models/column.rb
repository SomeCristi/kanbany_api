class Column < ApplicationRecord
  # Model associations
  belongs_to :board
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"

  # column cannot be deleted if it has tasks
  has_many :tasks, dependent: :restrict_with_error

  # Validations

  # Validates presence of those attributes
  # For board it checks if the record exists
  validates :created_by, :name, :board, :column_order, presence: true

  validate :check_column_order

  validates :column_order, numericality: { greater_than: 0 }

  validate :board_change, on: :update

  # Callbacks
  before_create :change_column_orders
  before_update :update_column_orders
  before_destroy :rearrange_columns

  private

  # If object is created or the column_order is being changed
  # Checks if column_order is not more than the last column_order + 1
  # Example: if the last column_order on a column is 3, the next one
  # cannot be 5
  def check_column_order
    # Checks if board is present
    # (not board id because an id that does not belong to a board can be provided)
    # in case this valdiation is run before the one that checks the presence of board
    # If board is nil the comparison inside the if failed
    # the same goes for column order
    if board.present? && self.column_order.present?
      if self.column_order > self.board.columns.count + 1
        errors.add(:column_order, 'must be maximum last column order + 1')
      end
    end
  end

  def rearrange_columns
    Column
      .where('column_order >=? AND board_id = ?', column_order, board_id)
      .update_all('column_order = column_order - 1')
  end

  # Updates all the columns that have column order greater or equal than
  # current column order to have their old order value + 1.
  # This uses only one SQL UPDATE Statement
  # Example: If there are 3 columns with order 1, 2, 3 and we want to add one column
  # on the second position, the columns that were on position 2 and 3 will be on position 3 and 4
  def change_column_orders
    Column
      .where("column_order >= ? AND board_id = ?", column_order, board_id)
      .update_all("column_order = column_order + 1")
  end

  # Checks if column order has changed and if so
  # checks if new order is bigger than old order(column was moved to the right)
  # in this case it will move the other columns accordingly:
  # all the columns with column order between the old and
  # the new order(and equal to new) of the current
  # column will have their column order reduced by 1
  # else, if the new order of the current column is less than the old one
  # (column was moved to the left) add + 1 to the columns orders
  # between the new(and equal) and the old one
  def update_column_orders
    if column_order_changed?
      if column_order > column_order_in_database
        column_moved_to_right
      else
        column_moved_to_left
      end
    end
  end

  def column_moved_to_right
    Column
      .where("column_order <= ? AND column_order > ? AND board_id = ?", column_order, column_order_in_database, board_id)
      .update_all("column_order = column_order -1")
  end

  def column_moved_to_left
    Column
      .where("column_order < ? AND column_order >= ? AND board_id = ?", column_order_in_database, column_order, board_id)
      .update_all("column_order = column_order + 1")
  end

  # this is not really necessary as board_id will not be accepted as
  # param in the columns controller
  def board_change
    errors.add(
      :base, 'moving a column to another board is forbidden'
    ) if board_id_changed?
  end
end
