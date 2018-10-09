# Auth

## Setup

###### backend/Gemfile

```ruby
...

# Use BCrypt for hashing
gem 'bcrypt'

# Use JWT for auth
gem 'jwt'

```

```bash
$ touch backend/lib/jwt_service.rb
```

###### backend/lib/jwt_service.rb

```ruby
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

```

<!-- remember this super_secret key for the frontend -->
```bash
$ cd backend/ && rails c && cd ..
> SecureRandom.base64
 => "super_secret"
```

###### config/application.yml

```yaml
...

JWT_KEY: 'super_secret'

```

###### backend/config/application.rb

```ruby
...

module Backend
  class Application < Rails::Application
    ...

    # Added

    ['app/serializers', 'lib'].each do |path|
      ...
    end
  end
end

```

```bash
$ touch backend/config/initializers/jwt_authenticator.rb
```

<!-- make this into a standalone class? would take request headers on init -->

###### backend/config/initializers/jwt_authenticator.rb

```ruby
require 'jwt_service'

module JwtAuthenticator
  def initialize(headers)
    @headers = headers
  end

  def invalid_token?
    bearer_header.nil? || invalid_claims
  end

  def claims
    return @claims if @claims

    strategy, token = bearer_header.split(' ')
    return nil if (strategy || '').downcase != 'bearer'
    @claims = JwtService.decode(token: token) rescue nil
  end

  private

  def bearer_header
    @headers['Authorization']&.to_s
  end

  def invalid_claims
    !claims || !claims['sub'] || expired || premature
  end

  def expired
    claims['exp'] && Time.now > Time.at(claims['exp'])
  end

  def premature
    claims['nbf'] && Time.now < Time.at(claims['nbf'])
  end
end

```

###### backend/app/controllers/application_controller.rb

```ruby
class ApplicationController < ActionController::API
  def authenticate_user!
    json = { error: 'Unauthorized' }
    render json: json, status: :unauthorized unless current_user
  end

  def current_user
    return @current_user if @current_user

    jwt_authenticator = JwtAuthenticator.new request.headers
    return if jwt_authenticator.invalid_token?
    @current_user = User.find_by_name claims['sub']
  end
end

```

```bash
$ rails g migration AddPasswordDigestToUsers password_digest:string
$ rails g model salt user:belongs_to salt_string:string
$ rails g scaffold_controller Salt
$ rails g model nonce user:belongs_to nonce_string:string expiration_at:datetime
$ rails g scaffold_controller Nonce
```

<!-- can you just use has_secure_password instead of redefining #authenticate and #password= ? -->
<!-- i think not because its PITA to override the authenticate_user! method in application_controller.rb -->
###### app/models/user.rb

```ruby
class User < ApplicationRecord
  def authenticate(unencrypted_password)
    BCrypt::Password.new(password_digest).is_password?(unencrypted_password) && self
  end

  def password=(unencrypted_password)
    self.password_digest = BCrypt::Password.create(unencrypted_password)
  end

  ...

  has_one :salt, dependent: :destroy

  has_one :nonce, dependent: :destroy

  def make_session
    payload = { sub: name }
    token = JwtService.encode(payload: payload)
    OpenStruct.new({ id: nil, user_name: name, token: token })
  end

  private

  ...
end

```
