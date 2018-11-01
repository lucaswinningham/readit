class SessionService
  def self.make_session(user)
    payload = { sub: user.name }
    token = JwtService.encode(payload: payload)
    OpenStruct.new({ id: nil, user_name: user.name, token: token })
  end
end
