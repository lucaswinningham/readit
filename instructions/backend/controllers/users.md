#### Users

```bash
$ rails g scaffold_controller user
$ rm spec/requests/users_spec.rb
```

###### spec/routing/users_routing_spec.rb

```ruby
require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    let(:existing_user) { create :user }
    let(:collection_route) { '/users' }
    let(:member_route) { "/users/#{existing_user.name}" }
    let(:member_params) { { name: existing_user.name } }

    it 'routes to #index' do
      expect(get: collection_route).to route_to('users#index')
    end

    it 'routes to #show' do
      expect(get: member_route).to route_to('users#show', member_params)
    end

    it 'routes to #create' do
      expect(post:collection_route).to route_to('users#create')
    end

    it 'routes to #update via PUT' do
      expect(put: member_route).to route_to('users#update', member_params)
    end

    it 'routes to #update via PATCH' do
      expect(patch: member_route).to route_to('users#update', member_params)
    end

    it 'routes to #destroy' do
      expect(delete: member_route).to route_to('users#destroy', member_params)
    end
  end
end

```

###### config/routes.rb

```ruby
Rails.application.routes.draw do
  resources :users, param: :name
end

```

```bash
$ rspec spec/routing
$ rubocop
```

###### spec/models/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'to_param' do
    it 'overrides #to_param with name attribute' do
      existing_user = create :user
      expect(existing_user.to_param).to eq(existing_user.name)
    end
  end
  
  ...
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  def to_param
    name
  end

  private

  ...
end
```

```bash
$ rspec spec/models
$ rubocop
```

###### spec/controllers/users_controller_spec.rb

```ruby
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      index_request = { params: {} }
      get :index, index_request

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      existing_user = create :user
      show_request = { params: { name: existing_user.to_param } }
      get :show, show_request

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested user' do
        new_user = build :user
        user_params = { name: new_user.name, email: new_user.email }
        create_request = { params: { user: user_params } }

        expect { post :create, create_request }.to change { User.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(user_url(User.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new user' do
        new_user = build :user, name: '', email: ''
        user_params = { name: new_user.name, email: new_user.email }
        create_request = { params: { user: user_params } }

        post :create, create_request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested user' do
        existing_user = create :user
        updated_user = build :user, name: 'other', email: 'other@email.com'
        user_params = { name: updated_user.name, email: updated_user.email }
        update_request = { params: { name: existing_user.to_param, user: user_params } }
        put :update, update_request

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        existing_user.reload
        assert_equal updated_user.name, existing_user.name
        assert_equal updated_user.email, existing_user.email
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the user' do
        existing_user = create :user
        updated_user = build :user, name: '', email: ''
        user_params = { name: updated_user.name, email: updated_user.email }
        update_request = { params: { name: existing_user.to_param, user: user_params } }
        put :update, update_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      existing_user = create :user
      destroy_request = { params: { name: existing_user.to_param } }

      expect { delete :destroy, destroy_request }.to change { User.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end

```

###### app/controllers/users_controller.rb

```ruby
class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.all

    render json: @users
  end

  def show
    render json: @user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  private

  def set_user
    @user = User.find_by_name!(params[:name])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

```

```bash
$ rspec
$ rubocop
```

