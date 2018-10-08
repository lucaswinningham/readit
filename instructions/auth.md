<!-- rails g model User name:string email:string password_digest:string -->
rails g model User password_digest:string
touch Gemfile <!-- bcrypt and dotenv-rails -->
gem install dotenv
touch .env
touch app/models/user.rb
touch lib/jwt_service.rb

touch app/controllers/salts_controller.rb
touch app/controllers/nonces_controller.rb
touch app/models/nonce.rb
touch app/controllers/sessions_controller.rb
touch config/routes.rb

touch config/application.rb
touch app/controllers/application_controller.rb
touch config/initializers/jwt_authenticator.rb
touch app/controllers/users_controller.rb <!-- line 2 -->
touch app/models/user.rb

touch serializers

rails c
user = User.new name: 'reddituser', email: 'reddituser@email.com', password: 'secret_password'
user.save
user.authenticate 'secret_password'

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
unencryped_password = 'secret_password'
hashed_password = BCrypt::Engine.hash_secret(unencryped_password, salt)
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
hashed_password = BCrypt::Engine.hash_secret(unencryped_password, salt)
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
