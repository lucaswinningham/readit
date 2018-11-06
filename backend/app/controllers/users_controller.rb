class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[update destroy]
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.all

    render json: UserSerializer.new(@users)
  end

  def show
    if @user
      render json: UserSerializer.new(@user)
    else
      json = { error: "User does not exist." }
      render json: json, status: :not_found
    end
  end

  def create
    user = User.new user_params
    user.build_salt salt_string: password_salt

    if user.save
      session = SessionService.make_session user
      # render json: SessionSerializer.new(session), status: :created
      render json: session, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # def update
  #   if @user.update(user_params)
  #     render json: SessionSerializer.new(@user)
  #   else
  #     render json: @user.errors, status: :unprocessable_entity
  #   end
  # end

  def destroy
    current_user.destroy
  end

  private

  def set_user
    @user = User.find_by_name params[:name]
  end

  def raw_params
    params.require(:user).permit(:name, :email, :password)
  end

  def user_params
    @user_params ||= raw_params.merge password: decrypted_password
  end

  def decrypted_password
    @decrypted_password ||= CipherService.decrypt raw_params[:password]
  end

  def password_salt
    BCrypt::Password.new(decrypted_password).salt
  end
end

# class UsersController < ApplicationController
#   before_action :set_user, only: %i[show update destroy]

#   def index
#     users = User.all
#     render json: UserSerializer.new(users)
#   end

#   def show
#     render json: UserSerializer.new(@user)
#   end

#   def create
#     user = User.new(user_params)

#     if user.save
#       render json: UserSerializer.new(user), status: :created
#     else
#       render json: user.errors, status: :unprocessable_entity
#     end
#   end

#   def update
#     if @user.update(user_params)
#       render json: UserSerializer.new(@user)
#     else
#       render json: @user.errors, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @user.destroy
#   end

#   private

#   def set_user
#     @user = User.find_by_name!(params[:name])
#   end

#   def user_params
#     params.require(:user).permit(:name, :email)
#   end
# end
