class SessionsController < ApplicationController
  before_action :set_user

  def create
    return render_unauthorized "Username #{create_params[:user_name]} does not exist" unless @user

    @nonce = Nonce.find_by_user_id(@user.id)
    return render_unauthorized 'Missing or invalid login nonce' unless valid_nonce

    decode_token
    return render_unauthorized 'Incorrect password' unless authentic_user
    return render_unauthorized 'Malformed login hash' unless authentic_hash

    @user.nonce.destroy
    session = @user.make_session
    render json: SessionSerializer.new(session), status: :created
  end

  private

  def create_params
    params.require(:session).permit(:user_name, :token)
  end

  def set_user
    @user = User.find_by_name create_params[:user_name]
  end

  def valid_nonce
    @nonce && !@nonce.expired?
  end

  def decode_token
    decoded_token = JwtService.decode(token: create_params[:token])

    @client_hashed_password = decoded_token['key']
    @cnonce = decoded_token['cnonce']
    @client_hash = decoded_token['hash']
  end

  def authentic_user
    @user && @user.authenticate(@client_hashed_password)
  end

  def authentic_hash
    string_to_digest = "#{@nonce.nonce_string}.#{@cnonce}.#{@client_hashed_password}"
    server_hash = Digest::SHA2.new(512).hexdigest(string_to_digest)
    @client_hash == server_hash
  end

  def render_unauthorized(error)
    json = { error: error }
    render json: json, status: :unauthorized
  end
end
