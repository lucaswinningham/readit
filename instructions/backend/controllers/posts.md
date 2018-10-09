#### Posts

```bash
$ rails g scaffold_controller post
$ rm spec/requests/posts_spec.rb
```

<!-- copy same format (route, params vars) to users and subs and so forth -->

###### spec/routing/posts_routing_spec.rb

```ruby
require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  describe 'routing' do
    let(:post) { create :post }

    it 'routes to #index' do
      route = "/users/#{post.user.name}/posts"
      params = { user_name: post.user.name }
      expect(get: route).to route_to('posts#index', params)

      route = "/subs/#{post.sub.name}/posts"
      params = { sub_name: post.sub.name }
      expect(get: route).to route_to('posts#index', params)
    end

    it 'routes to #show' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(get: route).to route_to('posts#show', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(get: route).to route_to('posts#show', params)
    end

    it 'routes to #create' do
      route = "/users/#{post.user.name}/posts"
      params = { user_name: post.user.name }
      expect(post: route).to route_to('posts#create', params)

      route = "/subs/#{post.sub.name}/posts"
      params = { sub_name: post.sub.name }
      expect(post: route).to route_to('posts#create', params)
    end

    it 'routes to #update via PUT' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(put: route).to route_to('posts#update', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(put: route).to route_to('posts#update', params)
    end

    it 'routes to #update via PATCH' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(patch: route).to route_to('posts#update', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(patch: route).to route_to('posts#update', params)
    end

    it 'routes to #destroy' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(delete: route).to route_to('posts#destroy', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(delete: route).to route_to('posts#destroy', params)
    end
  end
end

```

###### config/routes.rb

```ruby
Rails.application.routes.draw do
  concern(:postable) { resources :posts }
  
  user_concerns = [:postable]
  resources :users, param: :name, concerns: user_concerns

  sub_concerns = [:postable]
  resources :subs, param: :name, concerns: sub_concerns
end

```

###### spec/controllers/posts_controller_spec.rb

```ruby
require 'rails_helper'

RSpec.describe PostsController, type: :controller do
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
      post = create :post
      show_request = { params: { name: post.to_param } }
      get :show, show_request

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested post' do
        post = build :post
        post_params = { name: post.name }
        create_request = { params: { post: post_params } }

        expect { post :create, create_request }.to change { Post.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(post_url(Post.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new post' do
        post = build :post, name: ''
        post_params = { name: post.name }
        create_request = { params: { post: post_params } }

        post :create, create_request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested post' do
        original_post = create :post
        post = build :post, name: 'other'
        post_params = { name: post.name }
        update_request = { params: { name: original_post.to_param, post: post_params } }
        put :update, update_request

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        original_post.reload
        assert_equal post.name, original_post.name
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the post' do
        original_post = create :post
        post = build :post, name: ''
        post_params = { name: post.name }
        update_request = { params: { name: original_post.to_param, post: post_params } }
        put :update, update_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested post' do
      post = create :post
      destroy_request = { params: { name: post.to_param } }

      expect { delete :destroy, destroy_request }.to change { Post.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end

```

###### app/controllers/posts_controller.rb

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  def index
    @posts = Post.all

    render json: @posts
  end

  def show
    render json: @post
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
  end

  private

  def set_post
    @post = Post.find_by_name!(params[:name])
  end

  def post_params
    params.require(:post).permit(:name)
  end
end

```

```bash
$ rspec
$ rubocop
```

