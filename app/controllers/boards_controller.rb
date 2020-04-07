class BoardsController < ApplicationController

  # POST /boards
  def create
    board = Board.create!(board_params.merge(created_by: @current_user))
    json_response(board, :created)
  end

  private

  def board_params
    params.require(:board).permit(:name)
  end
end
