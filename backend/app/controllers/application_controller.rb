class ApplicationController < ActionController::API
  def authenticate_user!
    json = { error: 'Unauthorized' }
    render json: json, status: :unauthorized unless current_user
  end

  def current_user
    return @current_user if @current_user

    jwt_authenticator = JwtAuthenticator.new request.headers
    return if jwt_authenticator.invalid_token?
    @current_user = User.find_by_name jwt_authenticator.claims['sub']
  end
end
