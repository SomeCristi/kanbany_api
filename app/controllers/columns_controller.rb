class ColumnsController < ApplicationController
  before_action :set_column, only: [:show, :update]
  before_action :set_board

  # POST /boards/:board_id/columns
  # creates a new column record with the requested params
  # board id is taken from the current board which is taken from
  # the request's params
  # created_by_id attribute takes the current user's id
  # returns 201 if successful
  # returns 422 if the provided params are not good
  # returns 401 and an error message if request is unauthorized
  def create
    column = Column.create!(column_params.merge(created_by: @current_user, board_id: @board.id))
    json_response(column, :created)
  end

  # PUT/PATCH /boards/:board_id/columns/:id
  # updates the column with the requested params
  # returns 200 if successful
  # returns 422 if the provided params are not good
  # returns 404 if the resource does not exist
  # return 403 if user is not a member of the board
  # returns 401 and an error message if request is unauthorized
  def update
    @column.update!(column_params)
    json_response(@column)
  end

  # GET /boards/:board_id/columns/:id
  # returns the requested column
  # returns 200 if successful
  # returns 404 if resource does not exists
  # return 403 if user is not a member of the board
  # returns 401 and an error message if request is unauthorized
  def show
    json_response(@column)
  end

  # GET /boards/:board_id/columns
  # returns all the columns of the requested board
  # returns 200 if successful
  # returns 401 and an error message if request is unauthorized
  def index
    @columns = Column.where(board_id: @board).order(:column_order)
    json_response(@columns)
  end

  def destroy
    @column.destroy!
  end

  private

  def column_params
    params.require(:column).permit(:name, :column_order)
  end
end
