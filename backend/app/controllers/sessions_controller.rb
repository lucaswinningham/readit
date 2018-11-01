class SessionsController < ApplicationController
  before_action :set_user

  def create
    return render_unauthorized "Username #{create_params[:user_name]} does not exist" unless @user
    return render_unauthorized 'Missing or invalid login nonce' unless valid_nonce?
    return render_unauthorized 'Incorrect password' unless authentic_user?

    @user.nonce.destroy
    session = SessionService.make_session @user
    render json: SessionSerializer.new(session), status: :created
  end

  private

  # def create_params
  #   params.require(:session).permit(:user_name, :hash)
  # end

  def set_user
    # @user = User.find_by_name create_params[:user_name]
    @user = User.find_by_name session_params[:user_name]
  end

  def raw_params
    params.require(:session).permit(:user_name, :message)
  end

  def session_params
    @session_params ||= raw_params.merge password: decrypted_password
  end

  def decrypted_message
    return @decrypted_message if @decrypted_message
    nonce_string, password = CipherService.decrypt(raw_params[:message]).split('||')
    @decrypted_message = { nonce: nonce_string, password: password }
  end

  def decrypted_password
    @decrypted_password ||= decrypted_message[:password]
  end

  def nonce
    Nonce.find_by_user_id(@user.id)
  end

  def valid_nonce?
    nonce && !nonce.expired? && nonce.nonce_string == decrypted_message[:nonce]
  end

  def authentic_user?
    @user && @user.authenticate(decrypted_password)
  end

  def render_unauthorized(error)
    json = { error: error }
    render json: json, status: :unauthorized
  end
end
