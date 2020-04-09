class UsersController < ApplicationController
  skip_before_action :authorize_request, only: :create
  before_action :load_user, only: [:change_role]

  # POST /signup
  # return authenticated token upon signup
  def create
    user = User.create!(user_params)
    auth_token = AuthenticateUser.new(user.email, user.password).call
    response = { auth_token: auth_token }
    json_response(response, :created)
  end

  # PUT /users/:id/change_role
  # return user object
  # return 200 if successful
  # return 401 if unauthorized
  # return 422 is params are not valid
  # return 404 if user is not present
  def change_role
    authorize @user
    @user.update!(role_params)
    json_response({message: "Role changed successfully"})
  end

  private

  def user_params
    params
      .require(:user)
      .permit(
        :name,
        :email,
        :password,
        :password_confirmation
      )
  end

  def role_params
    params.require(:user).permit(:role)
  end

  def load_user
    @user = User.find(params[:id])
  end
end
