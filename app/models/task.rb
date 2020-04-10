class Task < ApplicationRecord
  # Model associations
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"
  # a ticket can be unassigned
  belongs_to :assigned_to, class_name: "User", foreign_key: "assigned_to_id", optional: true
  belongs_to :column

  # Validations
  validates :created_by, :title, :task_order, :column, presence: true
  validates :task_order, numericality: { greater_than: 0 }
  validate :check_task_order
  validate :assigned_to_user
  validate :column_from_same_board, on: :update, if: :column_id_changed?

  # Callbacks
  before_create :change_task_orders
  before_update :update_task_orders
  before_destroy :rearrange_tasks

  private

  # If object is created or the task_order is being changed
  # Checks if task_order is not more than the last task_order + 1
  # Example: if the last task_order on a column is 3, the next one
  # cannot be 5
  def check_task_order
    # Checks if column is present
    # (not column id because an id that does not belong to a column can be provided)
    # in case this valdiation is run before the one that checks the presence of column
    # If column is nil the comparison inside the if failed
    # the same goes for column order
    if column.present? && self.task_order.present?
      if self.task_order > self.column.tasks.count + 1
        errors.add(:task_order, 'must be maximum last task order + 1')
      end
    end
  end

  # Updates all the tasks that have task order greater or equal than
  # current task order to have their old order value + 1.
  # This uses only one SQL UPDATE Statement
  # Example: If there are 3 tasks with order 1, 2, 3 and we want to add one task
  # on the second position
  # the tasks that were on position 2 and 3 will be on position 3 and 4
  def change_task_orders
    Task
      .where("task_order >= ? AND column_id = ?", task_order, column_id)
      .update_all("task_order = task_order + 1")
  end
  # Check if column id of the task has changed. If so,
  # rearange tasks on both columns (initial task's column and new task's column)
  # If column id has not changed then check if task order has changed and if true
  # check if new order is bigger than old order(task was moved down)
  # in this case it will move the other tasks accordingly:
  # all the tasks with task order between the old and
  # the new order(and equal to new) of the current
  # task will have their task order reduced by 1
  # else, if the new order of the current task is less than the old one
  # (task was moved up) add + 1 to the tasks orders between the new(and equal) and the old one
  def update_task_orders
    if column_id_changed?
      rearrange_tasks_old_column
      rearrange_tasks_new_column
    else
      if task_order_changed?
        if task_order > task_order_in_database
          task_moved_down
        else
          task_moved_up
        end
      end
    end
  end

  def task_moved_down
    Task
      .where('task_order <= ? AND task_order > ? AND column_id = ?', task_order, task_order_in_database, column)
      .update_all('task_order = task_order -1')
  end

  def task_moved_up
    Task
      .where('task_order < ? AND task_order >= ? AND column_id = ?', task_order_in_database, task_order, column)
      .update_all('task_order = task_order + 1')
  end

  def rearrange_tasks
    Task
      .where('task_order >=? AND column_id = ?', task_order, column)
      .update_all('task_order = task_order - 1')
  end

  def assigned_to_user
    if assigned_to_id.present?
      user = User.where(id: assigned_to_id).first
      if user.blank?
        errors.add(
          :assigned_to_id,
          'has invalid value. User must exist.'
        ) if user.blank?
      else
        errors.add(
          :assigned_to_id,
          'must be a member of this board'
        ) unless user.boards.pluck(:id).include?(self.column.board.id)
      end
    end
  end

  def column_from_same_board
      new_column_board = column.board.id
      # use find as old column still exists
      # because a column with no tasks cannot
      # be deleted
      old_column_board = Column.find(column_id_in_database).board.id

      errors.add(
        :base,
        'cannot move task to another column'
      ) if new_column_board != old_column_board
  end

  def rearrange_tasks_new_column
    Task
      .where('column_id = ? AND task_order >= ?', column_id, task_order)
      .update_all('task_order = task_order + 1')
  end

  def rearrange_tasks_old_column
    Task
      .where('column_id = ? AND task_order > ?', column_id_in_database, task_order_in_database)
      .update_all('task_order = task_order -1')
  end
end
