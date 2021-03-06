class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]
  before_action :set_board
  before_action :set_column

  # POST /boards/:board_id/columns/:column_id/tasks
  # creates a new task record with the requested params
  # column id is taken from the current column which is taken from
  # the request's params
  # created_by_id attribute takes the current user's id
  # return 201 if successful
  # return 422 if the provided params are not good
  # return 401 and an error message if request is unauthorized
  # return 403 if current user is not a member of the board
  # return 404 if one of the used resources does not exist
  def create
    @task = Task.new(task_params.except(:column_id).merge(created_by: @current_user, column_id: @column.id))
    authorize @task
    @task.save!
    json_response(@task, :created)
  end

  # PUT /boards/:board_id/columns/:column_id/tasks/:id
  # updates the task with the requested params
  # if task's column is changed then the task order must be
  # provided
  # return 200 if successful
  # return 422 if the provided params are not good
  # return 404 if the resource does not exist
  # return 403 if current user is not a member of the board
  # return 401 and an error message if request is unauthorized
  def update
    @task.update!(task_params)
    json_response(@task)
  end

  # GET /boards/:board_id/columns/:column_id/tasks/:id
  # return the requested task
  # return 200 if successful
  # return 404 if resource does not exists
  # return 403 if current user is not a member of the board
  # return 401 and an error message if request is unauthorized
  # render 404 one of the used resources does not exist
  def show
    json_response(@task)
  end

  # GET /boards/:board_id/columns/:column_id/tasks
  # return all the tasks of the requested column
  # in ascending task order
  # return 200 if successful
  # return 401 and an error message if request is unauthorized
  # return 403 if current user is not a member of the board
  # render 404 one of the used resources does not exist
  def index
    @tasks = Task.where(column_id: @column.id).order(:task_order)
    json_response(@tasks)
  end

  # DELETE /boards/:board_id/columns/:column_id/tasks/:id
  # return 200 if successful and the deleted object
  # return 401 and an error message if request is unauthorized
  # return 422 if the deletion cannot be done + message error
  # return 403 if current user is not a member of the board
  # render 404 one of the used resources does not exist
  def destroy
    if @task.destroy
      json_response(@task)
    else
      json_response(@task.errors, :unprocessable_entity)
    end
  end

  private

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :created_by_id,
      :assigned_to_id,
      :task_order,
      :column_id
    )
  end

  def set_task
    @task = Task.where(id: params[:id], column_id: params[:column_id]).first
    json_response({ message: "Couldn't find Task with 'id'=#{params[:id]}"}, :not_found) unless @task
  end
end
