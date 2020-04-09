class MembershipsController < ApplicationController
  before_action :set_board

  # POST /boards/:board_id/memberships
  # creates a new membership record with the requested params
  # board id is taken from the current board which is taken from
  # the request's params
  # return 201 if successful
  # return 422 if the provided params are not good
  # return 401 and an error message if request is unauthorized
  # return 403 if user is not a member of the board
  def create
    membership = Membership.create!(membership_params.merge(board_id: @board.id))
    json_response(membership, :created)
  end

  private

  def membership_params
    params.require(:membership).permit(:user_id)
  end
end
