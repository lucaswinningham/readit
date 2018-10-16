class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[update destroy]
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.all

    render json: @users
  end

  def show
    # render json: UserShowSerializer.new(@user)
    render json: @user
  end

  def create
    user_params = create_params
    decoded = JwtService.decode(token: user_params.delete(:token))
    client_hashed_password = decoded['sub']
    user_params[:password] = client_hashed_password
    user = User.new(user_params)
    user.build_salt(salt_string: BCrypt::Password.new(client_hashed_password).salt)

    if user.save
      session = user.make_session
      # render json: SessionCreateSerializer.new(session), status: :created
      render json: session, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    # @user.destroy
    current_user.destroy
  end

  private

  def set_user
    @user = User.find_by_name!(params[:name])
  end

  def create_params
    # params.require(:user).permit(:name, :email)
    params.require(:user).permit(:name, :email, :token)
  end
end
