class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]
  before_action :set_board
  before_action :set_column

  # POST /boards/:board_id/columns/:column_id/tasks
  # creates a new task record with the requested params
  # column id is taken from the current column which is taken from
  # the request's params
  # created_by_id attribute takes the current user's id
  # returns 201 if successful
  # returns 422 if the provided params are not good
  # returns 401 and an error message if request is unauthorized
  def create
    task = Task.create!(task_params.merge(created_by: @current_user, column_id: @column.id))
    json_response(task, :created)
  end

  # PUT/PATCH /boards/:board_id/columns/:column_id/tasks/:id
  # updates the task with the requested params
  # returns 200 if successful
  # returns 422 if the provided params are not good
  # returns 404 if the resource does not exist
  # return 403 if user is not a member of the board
  # returns 401 and an error message if request is unauthorized
  def update
    @task.update!(task_params)
    json_response(@task)
  end

  # GET /boards/:board_id/columns/:column_id/tasks/:id
  # returns the requested task
  # returns 200 if successful
  # returns 404 if resource does not exists
  # return 403 if user is not a member of the board
  # returns 401 and an error message if request is unauthorized
  def show
    json_response(@task)
  end

  # GET /boards/:board_id/columns/:column_id/tasks
  # returns all the tasks of the requested column
  # in ascending task order
  # returns 200 if successful
  # returns 401 and an error message if request is unauthorized
  def index
    @tasks = Task.where(column_id: @column.id).order(:task_order)
    json_response(@tasks)
  end

  # DELETE /boards/:board_id/columns/:column_id/tasks/:id
  # returns 200 if successful and the deleted object
  # returns 401 and an error message if request is unauthorized
  # return 422 if the deletion cannot be done + message error
  def destroy
    if @task.destroy
      json_response(@task)
    else
      json_response(@task.errors, :unprocessable_entity)
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :created_by_id, :assigned_to_id, :task_order)
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
