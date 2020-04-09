class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :update]

  # POST /boards
  # creates a new board record with the requested params
  # created_by_id attribute takes the current user id
  # return 201 if successful
  # return 422 if the provided params are not good
  # return 401 and an error message if request is unauthorized
  def create
    @board = Board.new(board_params.merge(created_by: @current_user))
    authorize @board
    @board.save!
    json_response(@board, :created)
  end

  # PUT /boards/:id
  # updates the board with the requested params
  # return 200 if successful
  # return 422 if the provided params are not good
  # return 404 if the resource does not exist
  # return 403 if user is not a member
  # return 401 and an error message if request is unauthorized
  def update
    authorize @board
    @board.update!(board_params)
    json_response(@board)
  end

  # GET /boards/:id
  # return the requested board
  # return 200 if successful
  # return 404 if resource does not exists
  # return 403 if user is not a member
  # return 401 and an error message if request is unauthorized
  def show
    json_response(@board)
  end

  # GET /boards
  # return the boards of which the user is a member
  # return 200 if successful
  # return 401 and an error message if request is unauthorized
  def index
    @boards = Board.joins(:memberships).where('memberships.user_id= ?', @current_user.id)
    json_response(@boards)
  end

  # TODO add destroy method

  private

  def board_params
    params.require(:board).permit(:name)
  end

  # checks if the current user is a member of the requested board
  def has_membership?
    Membership.is_member?(@current_user.id, params[:id])
  end
end
