#### Users

```bash
$ rails g scaffold_controller User
$ rm spec/requests/users_spec.rb
$ touch spec/support/controller_helper.rb
```

###### spec/support/controller_helper.rb

```ruby

```

###### spec/rails_helper.rb

```ruby
...

RSpec.configure do |config|
  ...

  config.include Helpers::GenerationHelper, type: :model
  config.include Helpers::GenerationHelper, type: :controller
  config.include Helpers::GenerationHelper, type: :routing

  config.include Helpers::ControllerHelper, type: :controller

  # config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
end

...

```

```bash
$ touch lib/jwt_service.rb
$ touch config/initializers/json_web_token.rb
```

###### lib/jwt_service.rb

```ruby
class JwtService
  def self.encode(payload:)
    JWT.encode(payload, secret)
  end

  def self.decode(token:)
    JWT.decode(token, secret).first
  end

  def self.secret
    Rails.application.secrets.secret_key_base
  end
end

```

###### config/initializers/json_web_token.rb

```ruby
require 'jwt_service'

module Devise
  module Strategies
    class JsonWebToken < Base
      def valid?
        bearer_header.present?
      end

      def authenticate!
        return if no_auth
        success! User.find_by_id claims['user_id']
      end

      private

      def bearer_header
        request.headers['Authorization']&.to_s
      end

      def claims
        strategy, token = bearer_header.split(' ')
        return nil if (strategy || '').downcase != 'bearer'
        JwtService.decode(token: token) rescue nil
      end

      def no_auth
        no_claims || no_claimed_user_id || no_claimed_expiry || expired_token
      end

      def no_claims
        !claims
      end

      def no_claimed_user_id
        !claims.has_key?('user_id')
      end

      def no_claimed_expiry
        !claims.has_key?('expiry')
      end

      def expired_token
        Time.now > Time.parse(claims['expiry'])
      end
    end
  end
end

```

###### config/initializers/devise.rb

```ruby
Devise.setup do |config|
  ...
  config.secret_key = 'AUTO_GENERATED_KEY'

  ...

  config.warden do |manager|
    manager.strategies.add(:jwt, Devise::Strategies::JsonWebToken)
    manager.default_strategies(scope: :user).unshift :jwt
  end

  ...
end
```

```bash
$ mkdir app/controllers/users
$ touch app/controllers/users/sessions_controller.rb
```

###### app/controllers/users/sessions_controller.rb

```ruby
module Users
  class SessionsController < Devise::SessionsController
    def create
      super do |user|
        @user = user
        if @user.persisted?
          render json: { user: @user, token: build_token }.to_json
          return
        end
      end
    end

    private

    def build_token
      payload = { user_id: @user.id, expiry: (Time.now + 12.hours).to_s }
      JwtService.encode(payload: payload)
    end
  end
end

```

###### config/routes.rb

```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  resources :users, only: %i[show destroy]
end

```

###### spec/routing/users_routing_spec.rb

```ruby
require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/user/1').to route_to('users#show', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/user/1').to route_to('users#destroy', id: '1')
    end
  end
end

```

###### spec/controllers/users_controller_spec.rb

```ruby
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #show' do
    it 'returns a success response' do
      existing_user = create_user
      show_request = { params: { id: existing_user.to_param } }
      get :show, show_request
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      existing_user = create_user
      destroy_request = { params: { id: existing_user.to_param } }
      sign_in existing_user
      expect { delete :destroy, destroy_request }.to change { User.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end

```

###### app/controllers/users_controller.rb

```ruby
class UsersController < ApplicationController
  before_action :authenticate_user!, only: :destroy
  before_action :set_user

  def show
    render json: @user
  end

  def destroy
    @user.destroy
  end

  private

  def set_user
    @user = User.find(params[:name])
  end
end

```

