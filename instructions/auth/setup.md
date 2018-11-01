

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
      uses the salt to hash the plain text password
      encrypts hashed password using mutual key and initialization vector
      sends user's name, email and encrypted hashed password
    server
      whitelists params of user's name, email and encrypted hashed password
      decrypts the encrypted hashed password getting the hashed password
      initializes a new user
      saves user salt associated with hashed password
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
      uses the salt to hash the plain text password
      encrypts a message consisting of "nonce||hashed_password" using mutual key and initialization vector
      requests a new session with user's name and encrypted message
    server
      whitelists params of user's name and encrypted  message
        verifies user exists
      retrieves nonce associated to user
      decrypts message getting nonce and client hashed password
        verifies nonce retrieved is the same as in message
        verifies nonce exists for user and is not expired
        authenticates user with client hash password
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

```bash
$ rails g serializer Salt salt_string
```

<!-- figure out how to return user name and not its id using the fast json api -->
###### app/serializers/salt_serializer.rb

```ruby
class SaltSerializer
  ...

  belongs_to :user
end

```

###### app/controllers/salts_controller.rb

```ruby
class SaltsController < ApplicationController
  before_action :set_user

  def show
    if @user
      render json: SaltSerializer.new(@user.salt)
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

```bash
$ rspec
$ rubocop
```

<!-- move this to somewhere before here -->
#### Auth Cipher

```bash
$ touch lib/cipher_service.rb
```

###### lib/cipher_service.rb

```ruby
class CipherService
  def self.encrypt(plain_text)
    cipher = new_cipher
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv
    encrypted = cipher.update(plain_text) + cipher.final
    encoded = Base64.encode64(encrypted)
  end

  def self.decrypt(encoded)
    decoded = Base64.decode64(encoded)
    cipher = new_cipher
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    decrypted = cipher.update(decoded) + cipher.final
  end

  def self.new_cipher
    OpenSSL::Cipher::AES128.new(:CBC)
  end

  def self.key
    Base64.decode64(ENV['CIPHER_KEY'])
  end

  def self.iv
    Base64.decode64(ENV['CIPHER_IV'])
  end
end

```

Remember this key and iv for the frontend

```bash
$ rails c
> cipher = OpenSSL::Cipher::AES128.new(:CBC)
> cipher.encrypt
> raw_key = cipher.random_key
> raw_iv = cipher.random_iv
> encoded_key = Base64.encode64(raw_key)
 => "secret_encyption_key"
> encoded_iv = Base64.encode64(raw_iv)
 => "secret_encyption_iv"
```

###### config/application.yml

```yaml
...

CIPHER_KEY: 'secret_encryption_key'
CIPHER_IV: 'secret_encryption_iv'

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

```bash
$ rails g serializer Session user_name token
```

###### app/controllers/sessions_controller.rb

```ruby

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

  validates :nonce_string, presence: true, allow_blank: false, length: { minimum: 24, maximum: 24 }

  def self.generate_nonce
    SecureRandom.base64
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

```bash
$ rails g serializer Nonce nonce_string
```

<!-- figure out how to return user name and not its id using the fast json api -->
###### app/serializers/nonce_serializer.rb

```ruby
class NonceSerializer
  ...

  belongs_to :user
end

```

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

Remember this key for the frontend

```bash
$ rails c
> SecureRandom.hex # remember this for the frontend
 => "secret_jwt_key"
```

###### config/application.yml

```yaml
...

JWT_KEY: 'secret_jwt_key'

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

#### Auth Jwt Authenticator

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

#### Auth Session Service

```bash
$ touch lib/session_service.rb
```

<!-- rename #make_session to reflect purpose of creating open struct with id nil for netflix fast json api -->
###### lib/session_service.rb

```ruby

```

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

  private

  ...
end

```

#### Auth Users Controller

###### spec/controllers/users_controller_spec.rb

###### app/controllers/users_controller.rb

```ruby

```

<!-- serializers -->

Mock of the cycle

GET salt

curl -X GET http://localhost:3000/users/reddituser/salt | jq

POST to users

rails c
salt = 'FILL_IN_salt_string_from_above'
unencrypted_password = 'secret_password'
hashed_password = BCrypt::Engine.hash_secret(unencrypted_password, salt)
password = CipherService.encrypt(hashed_password)

curl -X POST -H Content-Type:application/json -H Accept:application/json http://localhost:3000/users -d '{"user":{"email":"reddituser@email.com","name":"reddituser","password":"FILL_IN_password_from_above"}}' | jq

GET salt

curl -X GET http://localhost:3000/users/reddituser/salt | jq

POST to nonce

curl -X POST -H Content-Type:application/json -H Accept:application/json http://localhost:3000/users/reddituser/nonce | jq

POST to sessions

rails c
salt = 'FILL_IN_salt_string_from_above'
nonce = 'FILL_IN_nonce_string_from_above'
unencrypted_password = 'secret_password'
hashed_password = BCrypt::Engine.hash_secret(unencrypted_password, salt)
message = CipherService.encrypt("#{nonce}||#{hashed_password}")

curl -X POST -H Content-Type:application/json -H Accept:application/json http://localhost:3000/sessions -d '{"session":{"user_name":"reddituser","message":"FILL_IN_message_from_above"}}' | jq

GET user

curl -X GET http://localhost:3000/users/reddituser | jq

DELETE user

curl -X DELETE -H Content-Type:application/json -H Accept:application/json -H "Authorization:Bearer some.token.here" http://localhost:3000/users/reddituser | jq



<!-- explanation here, mostly mirroring these links -->
<!-- https://stackoverflow.com/questions/3391242/should-i-hash-the-password-before-sending-it-to-the-server-side -->
<!-- https://security.stackexchange.com/questions/3001/what-is-the-use-of-a-client-nonce -->

the reason the methodology is not strictly followed in the second link (stackexchange), is that the user's password could not be hashed before saving to the database for the purposes of login hash recalculation. simply for the fact that any password could be transmitted during sign up, it's imperative to hash the user's password before saving. the methodology in the first link is followed save the fact that it mistakenly mentions "serving a nonce to hash with the hashed password such that the nonce could be reversed on the server" which is supposed to read "serving a nonce to encrypt with the hashed password such that the encrypted message could be decrypted on the server to retrieve the hashed password". except this means that there are no calculations to check against. after revisiting the second link, it seems that it is getting at the fact that the server database is saving plain text passwords, at which point it's necessary to follow its methodology. this application nor any application i ever create will save passwords in plain text. for this reason, the second link seems irrelevant.

so im tinking what you do is on sign up, hash the password, then encrypt it with jwt just like it is now.
then decrypt the jwt to get the original hashed password,
but on log in, follow what the second link says which is to actually hash the combination not just encrypt it
then check on the other side the hashing of the nonce, cnonce, and hashed password

this differs from how it is now which is at both sign up and login,
  the nonce cnonce and hashed password are encrypted then decrypted then the password is then again hashed

which one is better?
  one only stores the original hashed password into the database
    if the database is compromised, an attacker would gain access as users
  the other hashes the hashed password again.
    if the database is compromised, an attacker couldn't gain access from a "plain text" hashed password
    but the hashed password is plain if the jwt is intercepted and the attacker could gain user's access that way

let p: plain text password
let h: hashing algorithm
let e: encryption algorithm
let e': decryption algorithm
let n: server provided nonce (challenge)
let c: client provided cnonce

in order of security

option 1:
client sends p
server saves p
database reveals all users' p
man in the middle reveals user's p
replay gives user's access

So don't save passwords in plain text

option 2:
client sends p
server saves h(p)
man in the middle reveals user's p
replay gives user's access

So don't send the user's password in plain text

option 2:
client sends h(p)
server saves h(h(p))
replay gives user's access

So supply a nonce that the server checks against and expires

option 3:
server sends n
client sends e(n || h(p))
server saves h(h(p)) for h(p) of e'(n || h(p))
man in the middle + supplied nonce + rainbow table gives user's access

So supply a client nonce

option 4:
server sends n
client sends c || e(n || c || h(p))
server saves h(h(p)) for h(p) of e'(n || c || h(p))


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

