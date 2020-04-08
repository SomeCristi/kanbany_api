class BoardsController < ApplicationController
  before_action :set_board, if: :has_membership?, only: [:show, :update, :destroy]

  # POST /boards
  def create
    board = Board.create!(board_params.merge(created_by: @current_user))
    json_response(board, :created)
  end

  # PUT /boards
  def update
    @board.update!(board_params)
    json_response(@board)
  end

  private

  def board_params
    params.require(:board).permit(:name)
  end

  def set_board
    @board = Board.find(params[:id])
  end

  def has_membership?
    Membership.is_member?(@current_user.id, params[:id])
  end
end
