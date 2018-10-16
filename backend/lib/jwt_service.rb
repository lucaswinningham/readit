class JwtService
  def self.encode(payload:)
    now = Time.now.to_i
    payload[:iat] = now
    payload[:nbf] = now
    payload[:exp] = 2.hours.from_now.to_i
    JWT.encode(payload, secret)
  end

  def self.decode(token:)
    JWT.decode(token, secret).first
  end

  def self.secret
    ENV['JWT_KEY']
  end
end
