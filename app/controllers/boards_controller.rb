class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :update]

  # POST /boards
  # creates a new board record with the requested params
  # created_by_id attribute takes the current user id
  # returns 201 if successful
  # returns 422 if the provided params are not good
  # returns 401 and an error message if request is unauthorized
  def create
    board = Board.create!(board_params.merge(created_by: @current_user))
    json_response(board, :created)
  end

  # PUT/PATCH /boards/:id
  # updates the board with the requested params
  # returns 200 if successful
  # returns 422 if the provided params are not good
  # returns 404 if the resource does not exist
  # return 403 if user is not a member
  # returns 401 and an error message if request is unauthorized
  def update
    @board.update!(board_params)
    json_response(@board)
  end

  # GET /boards/:id
  # returns the requested board
  # returns 200 if successful
  # returns 404 if resource does not exists
  # return 403 if user is not a member
  # returns 401 and an error message if request is unauthorized
  def show
    json_response(@board)
  end

  # GET /boards
  # returns the boards of which the user is a member
  # returns 200 if successful
  # returns 401 and an error message if request is unauthorized
  def index
    @boards = Board.joins(:memberships).where('memberships.user_id= ?', @current_user.id)
    json_response(@boards)
  end

  # TODO add destroy

  private

  def board_params
    params.require(:board).permit(:name)
  end

  # checks if the current user is a member of the requested board
  def has_membership?
    Membership.is_member?(@current_user.id, params[:id])
  end
end
