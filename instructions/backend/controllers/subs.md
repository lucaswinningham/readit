#### Subs

```bash
$ rails g scaffold_controller sub
$ rm spec/requests/subs_spec.rb
```

###### spec/routing/subs_routing_spec.rb

```ruby
require 'rails_helper'

RSpec.describe SubsController, type: :routing do
  describe 'routing' do
    let(:sub) { create :sub }

    it 'routes to #index' do
      expect(get: '/subs').to route_to('subs#index')
    end

    it 'routes to #show' do
      expect(get: "/subs/#{sub.name}").to route_to('subs#show', name: sub.name)
    end

    it 'routes to #create' do
      expect(post: '/subs').to route_to('subs#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/subs/#{sub.name}").to route_to('subs#update', name: sub.name)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/subs/#{sub.name}").to route_to('subs#update', name: sub.name)
    end

    it 'routes to #destroy' do
      expect(delete: "/subs/#{sub.name}").to route_to('subs#destroy', name: sub.name)
    end
  end
end

```

###### config/routes.rb

```ruby
Rails.application.routes.draw do
  ...

  resources :subs, param: :name
end

```

```bash
$ rspec spec/routing
$ rubocop
```

###### spec/models/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  describe 'to_param' do
    it 'overrides #to_param with name attribute' do
      sub = create :sub
      expect(sub.to_param).to eq(sub.name)
    end
  end
  
  ...
end

```

###### app/models/sub.rb

```ruby
class Sub < ActiveRecord::Base
  ...

  def to_param
    name
  end
end
```

```bash
$ rspec spec/models
$ rubocop
```

###### spec/controllers/subs_controller_spec.rb

```ruby
require 'rails_helper'

RSpec.describe SubsController, type: :controller do
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
      sub = create :sub
      show_request = { params: { name: sub.to_param } }
      get :show, show_request

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested sub' do
        sub = build :sub
        sub_params = { name: sub.name }
        create_request = { params: { sub: sub_params } }

        expect { post :create, create_request }.to change { Sub.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(sub_url(Sub.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new sub' do
        sub = build :sub, name: ''
        sub_params = { name: sub.name }
        create_request = { params: { sub: sub_params } }

        post :create, create_request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested sub' do
        original_sub = create :sub
        sub = build :sub, name: 'other'
        sub_params = { name: sub.name }
        update_request = { params: { name: original_sub.to_param, sub: sub_params } }
        put :update, update_request

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        original_sub.reload
        assert_equal sub.name, original_sub.name
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the sub' do
        original_sub = create :sub
        sub = build :sub, name: ''
        sub_params = { name: sub.name }
        update_request = { params: { name: original_sub.to_param, sub: sub_params } }
        put :update, update_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested sub' do
      sub = create :sub
      destroy_request = { params: { name: sub.to_param } }

      expect { delete :destroy, destroy_request }.to change { Sub.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end

```

###### app/controllers/subs_controller.rb

```ruby
class SubsController < ApplicationController
  before_action :set_sub, only: %i[show update destroy]

  def index
    @subs = Sub.all

    render json: @subs
  end

  def show
    render json: @sub
  end

  def create
    @sub = Sub.new(sub_params)

    if @sub.save
      render json: @sub, status: :created, location: @sub
    else
      render json: @sub.errors, status: :unprocessable_entity
    end
  end

  def update
    if @sub.update(sub_params)
      render json: @sub
    else
      render json: @sub.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @sub.destroy
  end

  private

  def set_sub
    @sub = Sub.find_by_name!(params[:name])
  end

  def sub_params
    params.require(:sub).permit(:name)
  end
end

```

```bash
$ rspec
$ rubocop
```

