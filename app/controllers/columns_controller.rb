class ColumnsController < ApplicationController
  before_action :set_column, only: [:show, :update, :destroy]
  before_action :set_board

  # POST /boards/:board_id/columns
  # creates a new column record with the requested params
  # board id is taken from the current board which is taken from
  # the request's params
  # created_by_id attribute takes the current user's id
  # return 201 if successful
  # return 422 if the provided params are not good
  # return 401 and an error message if request is unauthorized
  # return 403 if current user is not a member of the board
  # return 404 if the board does not exist
  def create
    @column = Column.new(column_params.merge(created_by: @current_user, board_id: @board.id))
    authorize @column
    @column.save!
    json_response(@column, :created)
  end

  # PUT /boards/:board_id/columns/:id
  # updates the column with the requested params
  # return 200 if successful
  # return 422 if the provided params are not good
  # return 404 if the resource does not exist
  # return 401 and an error message if request is unauthorized
  # return 403 if current user is not a member of the board
  def update
    authorize @column
    @column.update!(column_params)
    json_response(@column)
  end

  # GET /boards/:board_id/columns/:id
  # return the requested column
  # return 200 if successful
  # return 404 if resource or the board does not exist
  # return 401 and an error message if request is unauthorized
  # return 403 if current user is not a member of the board
  def show
    json_response(@column)
  end

  # GET /boards/:board_id/columns
  # return all the columns of the requested board
  # in ascending column order
  # return 200 if successful
  # return 404 if the board does not exist
  # return 401 and an error message if request is unauthorized
  # return 403 if current user is not a member of the board
  def index
    @columns = Column.where(board_id: @board.id).order(:column_order)
    json_response(@columns)
  end

  # DELETE /boards/:board_id/columns/:id
  # return 200 if successful and the deleted object
  # return 401 and an error message if request is unauthorized
  # return 422 if the deletion cannot be done + message error
  # return 403 if current user is not a member of the board
  # record can only be deleted if it has no tasks
  def destroy
    if @column.destroy
      json_response(@column)
    else
      json_response(@column.errors, :unprocessable_entity)
    end
  end

  private

  def column_params
    params.require(:column).permit(:name, :column_order)
  end
end
