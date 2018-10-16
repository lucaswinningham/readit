class NoncesController < ApplicationController
  before_action :set_user

  def create
    return render_unauthorized "Username #{params[:user_name]} does not exist" unless @user

    nonce = @user.build_nonce(nonce_creation_attributes)

    if nonce.save
      # render json: NonceCreateSerializer.new(nonce), status: :created
      render json: nonce, status: :created
    else
      render json: nonce.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by_name params[:user_name]
  end

  def nonce_creation_attributes
    { user_id: @user.id, nonce_string: Nonce.generate_nonce, expiration_at: 5.minutes.from_now }
  end

  # move up a level since this is shared with sessions controller
  # maybe make an auth controller that this and sessions and maybe other controllers can inherit from
  # application_controller can use this as well
  def render_unauthorized(error)
    json = { error: error }
    render json: json, status: :unauthorized
  end
end
