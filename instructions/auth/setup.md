<!-- high level description here -->

```bash
$ cd backend/
```

###### Gemfile

```ruby
...

# Use BCrypt for hashing
gem 'bcrypt'

# Use JWT for auth
gem 'jwt'

```

```bash
$ bundle
```

<!-- move this after the other stuff, before controller spec modifications? -->
#### Auth Json Web Token

```bash
$ touch lib/jwt_service.rb
```

###### lib/jwt_service.rb

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
$ rails c
> SecureRandom.base64 # remember this for the frontend
 => "super_secret"
```

###### config/application.yml

```yaml
...

JWT_KEY: 'super_secret'

```

###### config/application.rb

```ruby
...

module Backend
  class Application < Rails::Application
    ...

    #
    # Added
    #

    ...

    # config.eager_load_paths << Rails.root.join('app/serializers')
    ['app/serializers', 'lib'].each do |path|
      config.eager_load_paths << Rails.root.join(path)
    end
  end
end

```

```bash
$ touch config/initializers/jwt_authenticator.rb
```

###### config/initializers/jwt_authenticator.rb

```ruby
require 'jwt_service'

class JwtAuthenticator
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
    @bearer_header ||= @headers['Authorization']&.to_s
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

###### app/controllers/application_controller.rb

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
    @current_user = User.find_by_name jwt_authenticator.claims['sub']
  end
end

```

<!-- add some bash proof here to make sense of what just happened -->

#### Auth User Model

```bash
$ rails g migration AddPasswordDigestToUsers password_digest:string
$ rails db:migrate
```

###### spec/factories/users.rb

###### spec/models/user_spec.rb

<!-- can you just use has_secure_password instead of redefining #authenticate and #password= ? -->
<!-- i think not because its PITA to override the authenticate_user! method in application_controller.rb -->
<!-- revisit and reconfirm above -->
<!-- move #make_session to a service or something, i dont think it belongs in this model -->
<!-- the service would most likely be a class that takes a username as init param with a #make_session -->
###### app/models/user.rb

```ruby
class User < ApplicationRecord
  # before_action: :authenticate_user!, only: %i[update delete]
  ...

  # password validations

  has_one :salt, dependent: :destroy

  has_one :nonce, dependent: :destroy

  def authenticate(unencrypted_password)
    BCrypt::Password.new(password_digest).is_password?(unencrypted_password) && self
  end

  def password=(unencrypted_password)
    self.password_digest = BCrypt::Password.create(unencrypted_password)
  end

  def make_session
    payload = { sub: name }
    token = JwtService.encode(payload: payload)
    OpenStruct.new({ id: nil, user_name: name, token: token })
  end

  private

  ...
end

```

#### Auth Users Controller

###### spec/controllers/users_controller_spec.rb

###### app/controllers/users_controller.rb

```ruby
class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[update destroy]
  before_action :set_user, only: %i[show update destroy]

  # def index
  #   @users = User.all

  #   render json: @users
  # end

  def show
    render json: UserSerializer.new(@user)
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
      render json: SessionSerializer.new(session), status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: UserPrivateSerializer.new(@user)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
  end

  private

  def set_user
    @user = User.find_by_name!(params[:name])
  end

  def create_params
    params.require(:user).permit(:name, :email, :token)
  end
end

```

<!-- serializers -->

#### Auth Salt Model

```bash
$ rails g model salt user:belongs_to salt_string:string
$ rails db:migrate
```

###### spec/factories/salts.rb

###### spec/models/salt_spec.rb

###### app/models/salt.rb

```ruby
class Salt < ApplicationRecord
  belongs_to :user

  def self.generate_salt
    BCrypt::Engine.generate_salt
  end
end

```

```ruby

```

```bash
$ rspec
$ rubocop
```

#### Auth Salts Controller

```bash
$ rails g scaffold_controller salt
```

###### spec/routings/salts_routing_spec.rb

###### config/routes.rb

```ruby
Rails.application.routes.draw do
  ...
  concern(:saltable) { resource :salt, only: :show }

  user_concerns = %i[... saltable]
  ...
end

```

```bash
$ rspec
$ rubocop
```

###### spec/controllers/salts_controller_spec.rb

###### app/controllers/salts_controller.rb

```ruby
class SaltsController < ApplicationController
  before_action :set_user

  def show
    if @user
      render json: SaltShowSerializer.new(@user.salt)
    else
      salt = Salt.new(salt_string: Salt.generate_salt)
      render json: SaltSerializer.new(salt)
    end
  end

  private

  def set_user
    @user = User.find_by_name params[:user_name]
  end
end

```

<!-- serializers -->

```bash
$ rspec
$ rubocop
```

#### Auth Nonce Model

```bash
$ rails g model nonce user:belongs_to nonce_string:string expiration_at:datetime
$ rails db:migrate
```

###### spec/factories/nonces.rb

###### spec/models/nonce_spec.rb

###### app/models/nonce.rb

```ruby
class Nonce < ApplicationRecord
  belongs_to :user

  validates :nonce_string, presence: true, allow_blank: false, length: { minimum: 128, maximum: 128 }

  def self.generate_nonce
    Digest::SHA2.new(512).hexdigest(SecureRandom.hex)
  end

  def expired?
    Time.now > Time.at(expiration_at)
  end
end

```

```bash
$ rspec
$ rubocop
```

#### Auth Nonces Controller

```bash
$ rails g scaffold_controller nonce
```

###### spec/routings/nonces_routing_spec.rb

###### config/routes.rb

```ruby
Rails.application.routes.draw do
  ...
  concern(:nonceable) { resource :nonce, only: :create }

  user_concerns = %i[... nonceable]
  ...
end

```

```bash
$ rspec
$ rubocop
```

###### spec/controllers/nonces_controller_spec.rb

###### app/controllers/nonces_controller.rb

```ruby
class NoncesController < ApplicationController
  before_action :set_user

  def create
    return render_unauthorized "Username #{params[:user_name]} does not exist" unless @user

    nonce = @user.build_nonce(nonce_creation_attributes)

    if nonce.save
      render json: NonceSerializer.new(nonce), status: :created
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

```

<!-- serializers -->

```bash
$ rspec
$ rubocop
```

#### Auth Sessions Controller

```bash
$ rails g scaffold_controller session
```

###### spec/routings/sessions_routing_spec.rb

###### config/routes.rb

```ruby
Rails.application.routes.draw do
  ...

  resources :sessions, only: :create
end

```

```bash
$ rspec
$ rubocop
```

###### spec/controllers/sessions_controller_spec.rb

###### app/controllers/sessions_controller.rb

```ruby
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

```

<!-- serializers -->

```bash
$ rspec
$ rubocop
```

<!-- all kinds of modifications to controller specs here for authentication -->
<!-- explanations of why these modifications need to happen -->
<!-- bash proof of these backend modifications -->

rails c
user = User.new name: 'reddituser', email: 'reddituser@email.com', password: 'secret_password'
user.save
user.authenticate 'secret_password'
user.destroy

user life cycle
  get user's salt
    client
      requests user's salt
    server
      responds with a generated new salt if the user does not exist
      otherwise responds with the user's salt
  post to users
    client
      requests user's salt
    server
      responds with the user's salt
    client
      uses the salt to hash the unencrypted password
      generates jwt with hashed password as payload's sub[ject]
    server
      whitelists params of user's name, email and a token
      decodes jwt getting the client hashed password
      initializes a new user
      retrieves the salt used to hash the client hashed password
      saves user
      creates and responds with a new user session giving auth jwt
  post to sessions
    client
      requests user's salt
    server
      responds with the user's salt
    client
      requests a new nonce associated with user
        verifies user exists
    server
      responds with a generated nonce associated to user
    client
      hashes user's unecrypted password yielding a client hashed password
      generates a c[lient_]nonce
      generates a client hash consisting of 'nonce.cnonce.client_hashed_password'
      generates jwt with key as client_hashed_password, cnonce, and hash as client hash
      requests a new session with user's name and jwt
    server
      whitelists params of user's name and a token
        verifies user exists
      retrieves nonce associated to user
        verifies nonce exists for user and is not expired
      decodes jwt getting client hashed password, cnonce, and client hash
        authenticates user with client hash password
        authenticates client hash by rebuilding using the same steps as client and checking equality
        destroys nonce associated with user
      creates and responds with a new user session giving auth jwt
  get user
    client
      requests user
    server
      responds with the user
  delete user
    client
      requests user to be deleted
    server
      authenticates user with auth jwt
      deletes user

GET salt

curl -X GET http://localhost:3000/users/reddituser/salt | jq

POST to users

salt = 'FILL_IN_salt_string_from_above'
unencrypted_password = 'secret_password'
hashed_password = BCrypt::Engine.hash_secret(unencrypted_password, salt)
payload = { sub: hashed_password }
JwtService.encode(payload: payload)

curl -X POST -H Content-Type:application/json -H Accept:application/json http://localhost:3000/users -d '{"user":{"email":"reddituser@email.com","name":"reddituser","token":"some.token.here"}}' | jq

GET salt

curl -X GET http://localhost:3000/users/reddituser/salt | jq

POST to nonce

curl -X POST -H Content-Type:application/json -H Accept:application/json http://localhost:3000/users/reddituser/nonce | jq

POST to sessions

salt = 'FILL_IN_salt_string_from_above'
nonce = 'FILL_IN_nonce_string_from_above'
cnonce = 'this_is_some_bogus_cnonce'
unencrypted_password = 'secret_password'
hashed_password = BCrypt::Engine.hash_secret(unencrypted_password, salt)
hash = Digest::SHA2.new(512).hexdigest("#{nonce}.#{cnonce}.#{hashed_password}")
payload = { key: hashed_password, cnonce: cnonce, hash: hash }
token = JwtService.encode(payload: payload)

curl -X POST -H Content-Type:application/json -H Accept:application/json http://localhost:3000/sessions -d '{"session":{"user_name":"reddituser","token":"some.token.here"}}' | jq

GET user

curl -X GET http://localhost:3000/users/reddituser | jq

DELETE user

curl -X DELETE -H Content-Type:application/json -H Accept:application/json -H "Authorization:Bearer some.token.here" http://localhost:3000/users/reddituser | jq



secret key for frontend and backend

SecureRandom.base64

touch backend/.env
touch frontend/src/environments/environment.ts

JWT::VerificationError (Signature verification raised):

lib/jwt_service.rb:11:in `decode'
app/controllers/sessions_controller.rb:31:in `decode_token'
app/controllers/sessions_controller.rb:9:in `create'

^^^ mismatched keys (forgot to match them or possible attack)



User shouldn't be able to perform any user actions until they have a role of 'user'
User gets role of 'user' when email is authenticated, more to come on that '/reddituser/confirmation' ?
ideas...
generate a nonce for email authentication to be included in a link in an email sent to the user
the nonce will be a param to the user's registration route which will check equality
user needs two new columns - confirmation_token, confirmed_at
user now needs roles

