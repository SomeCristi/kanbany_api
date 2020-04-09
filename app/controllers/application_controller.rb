class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include Pundit
  # called before every action on controllers
  before_action :authorize_request

  def set_board
    board_id = params[:board_id].present? ? params[:board_id] : params[:id]
    @board = Board.find(board_id)
    json_response({ message: "Forbidden from accessing this board" }, :forbidden) unless has_membership?
  end

  def set_column
    id = params[:column_id].present? ? params[:column_id] : params[:id]
    @column = Column.where(id: id, board_id: params[:board_id]).first
    json_response({ message: "Column with id #{id} not found"}, :not_found) unless @column
  end

  private

  # check if the current user is a member of the requested column
  def has_membership?
    Membership.is_member?(@current_user.id, @board.id)
  end

  # Check for valid request token and return user
  def authorize_request
    @current_user = (AuthorizeApiRequest.new(request.headers).call)[:user]
  end
end
