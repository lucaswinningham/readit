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
  let(:created_user) { create :user }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = { name: created_user.to_param }
      get :show, params: params

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested user' do
        new_user = build :user
        params = { user: new_user.as_json }

        expect { post :create, params: params }.to change { User.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new user' do
        new_user = build :user, name: '', email: ''
        params = { user: new_user.as_json }
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested user' do
        user_patch = build :user, name: 'other', email: 'other@email.com'
        params = { name: created_user.to_param, user: user_patch.as_json }
        put :update, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        created_user.reload
        assert_equal user_patch.name, created_user.name
        assert_equal user_patch.email, created_user.email
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the user' do
        user_patch = build :user, name: '', email: ''
        params = { name: created_user.to_param, user: user_patch.as_json }
        put :update, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      params = { name: created_user.to_param }

      expect { delete :destroy, params: params }.to change { User.count }.by(-1)

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
      render json: @user, status: :created
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

```
$ rails c
> require_relative 'spec/support/factories'
> 4.times { FactoryBot.create :user }
> FactoryBot.create :user, name: 'reddituser'
> quit
$ rails s
```

in another terminal

```bash
$ curl -X GET http://localhost:3000/users | jq
$ curl -X GET http://localhost:3000/users/reddituser | jq
$ curl -X PATCH -H Content-Type:application/json -H Accept:application/json http://localhost:3000/users/reddituser -d '{"user":{"name":"otheruser"}}' | jq
$ curl -X GET http://localhost:3000/users/otheruser | jq
$ curl -X DELETE http://localhost:3000/users/otheruser | jq
$ curl -X GET http://localhost:3000/users/otheruser | jq
```

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
    let(:existing_sub) { create :sub }
    let(:collection_route) { '/subs' }
    let(:member_route) { "/subs/#{existing_sub.name}" }
    let(:member_params) { { name: existing_sub.name } }

    it 'routes to #index' do
      expect(get: collection_route).to route_to('subs#index')
    end

    it 'routes to #show' do
      expect(get: member_route).to route_to('subs#show', member_params)
    end

    it 'routes to #create' do
      expect(post: collection_route).to route_to('subs#create')
    end

    it 'routes to #update via PUT' do
      expect(put: member_route).to route_to('subs#update', member_params)
    end

    it 'routes to #update via PATCH' do
      expect(patch: member_route).to route_to('subs#update', member_params)
    end

    it 'routes to #destroy' do
      expect(delete: member_route).to route_to('subs#destroy', member_params)
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
  let(:created_sub) { create :sub }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = { name: created_sub.to_param }
      get :show, params: params

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested sub' do
        new_sub = build :sub
        params = { sub: new_sub.as_json }

        expect { post :create, params: params }.to change { Sub.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new sub' do
        new_sub = build :sub, name: ''
        params = { sub: new_sub.as_json }
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested sub' do
        sub_patch = build :sub, name: 'other'
        params = { name: created_sub.to_param, sub: sub_patch.as_json }
        put :update, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        created_sub.reload
        assert_equal sub_patch.name, created_sub.name
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the sub' do
        sub_patch = build :sub, name: ''
        params = { name: created_sub.to_param, sub: sub_patch.as_json }
        put :update, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested sub' do
      params = { name: created_sub.to_param }

      expect { delete :destroy, params: params }.to change { Sub.count }.by(-1)

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
      render json: @sub, status: :created
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

```
$ rails c
> require_relative 'spec/support/factories'
> 4.times { FactoryBot.create :sub }
> FactoryBot.create :sub, name: 'redditsub'
> quit
$ rails s
```

in another terminal

```bash
$ curl -X GET http://localhost:3000/subs | jq
$ curl -X GET http://localhost:3000/subs/redditsub | jq
$ curl -X PATCH -H Content-Type:application/json -H Accept:application/json http://localhost:3000/subs/redditsub -d '{"sub":{"name":"othersub"}}' | jq
$ curl -X GET http://localhost:3000/subs/othersub | jq
$ curl -X DELETE http://localhost:3000/subs/othersub | jq
$ curl -X GET http://localhost:3000/subs/othersub | jq
```

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
    let(:existing_post) { create :post }

    describe 'users concerns' do
      let(:collection_route) { "/users/#{existing_post.user.name}/posts" }
      let(:member_route) { "/users/#{existing_post.user.name}/posts/#{existing_post.id}" }
      let(:collection_params) { { user_name: existing_post.user.name } }
      let(:member_params) { { user_name: existing_post.user.name, id: existing_post.to_param } }

      it 'routes to #index' do
        expect(get: collection_route).to route_to('posts#index', collection_params)
      end

      it 'routes to #show' do
        expect(get: member_route).to route_to('posts#show', member_params)
      end

      it 'routes to #create' do
        expect(post: collection_route).to route_to('posts#create', collection_params)
      end

      it 'routes to #update via PUT' do
        expect(put: member_route).to route_to('posts#update', member_params)
      end

      it 'routes to #update via PATCH' do
        expect(patch: member_route).to route_to('posts#update', member_params)
      end

      it 'routes to #destroy' do
        expect(delete: member_route).to route_to('posts#destroy', member_params)
      end
    end

    describe 'subs concerns' do
      let(:collection_route) { "/subs/#{existing_post.sub.name}/posts" }
      let(:member_route) { "/subs/#{existing_post.sub.name}/posts/#{existing_post.id}" }
      let(:collection_params) { { sub_name: existing_post.sub.name } }
      let(:member_params) { { sub_name: existing_post.sub.name, id: existing_post.to_param } }

      it 'routes to #index' do
        expect(get: collection_route).to route_to('posts#index', collection_params)
      end

      it 'routes to #show' do
        expect(get: member_route).to route_to('posts#show', member_params)
      end

      it 'routes to #create' do
        expect(post: collection_route).to route_to('posts#create', collection_params)
      end

      it 'routes to #update via PUT' do
        expect(put: member_route).to route_to('posts#update', member_params)
      end

      it 'routes to #update via PATCH' do
        expect(patch: member_route).to route_to('posts#update', member_params)
      end

      it 'routes to #destroy' do
        expect(delete: member_route).to route_to('posts#destroy', member_params)
      end
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
  let(:created_post) { create :post }

  describe 'users concerns' do
    describe 'GET #index' do
      it 'returns a success response' do
        params = { user_name: create(:user).name }
        get :index, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        params = { user_name: created_post.user.name, id: created_post.to_param }
        get :show, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'returns a success response and creates the requested post' do
          new_post = build :post
          params = { user_name: new_post.user.name, post: new_post.as_json }

          expect { post :create, params: params }.to change { Post.count }.by(1)

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the new post' do
          new_post = build :post, title: '', url: ''
          params = { user_name: new_post.user.name, post: new_post.as_json }
          post :create, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        it 'returns a success response and updates the requested post' do
          post_patch = build :post, title: 'other', url: 'http://www.other.com', body: 'body'
          user_name = created_post.user.name
          id = created_post.to_param
          params = { user_name: user_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')

          created_post.reload
          assert_equal post_patch.title, created_post.title
          assert_equal post_patch.url, created_post.url
          assert_equal post_patch.body, created_post.body
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the post' do
          post_patch = build :post, title: '', url: ''
          user_name = created_post.user.name
          id = created_post.to_param
          params = { user_name: user_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested post' do
        params = { user_name: created_post.user.name, id: created_post.to_param }

        expect { delete :destroy, params: params }.to change { Post.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'subs concerns' do
    describe 'GET #index' do
      it 'returns a success response' do
        params = { sub_name: create(:sub).name }
        get :index, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        params = { sub_name: created_post.sub.name, id: created_post.to_param }
        get :show, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'returns a success response and creates the requested post' do
          new_post = build :post
          params = { sub_name: new_post.sub.name, post: new_post.as_json }

          expect { post :create, params: params }.to change { Post.count }.by(1)

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the new post' do
          new_post = build :post, title: '', url: ''
          params = { sub_name: new_post.sub.name, post: new_post.as_json }
          post :create, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        it 'returns a success response and updates the requested post' do
          post_patch = build :post, title: 'other', url: 'http://www.other.com', body: 'body'
          sub_name = created_post.sub.name
          id = created_post.to_param
          params = { sub_name: sub_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')

          created_post.reload
          assert_equal post_patch.title, created_post.title
          assert_equal post_patch.url, created_post.url
          assert_equal post_patch.body, created_post.body
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the post' do
          post_patch = build :post, title: '', url: ''
          sub_name = created_post.sub.name
          id = created_post.to_param
          params = { sub_name: sub_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested post' do
        params = { sub_name: created_post.sub.name, id: created_post.to_param }

        expect { delete :destroy, params: params }.to change { Post.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end

```

###### app/controllers/posts_controller.rb

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  def index
    user = User.find_by_name params[:user_name]
    sub = Sub.find_by_name params[:sub_name]
    posts = (user || sub).posts

    render json: posts
  end

  def show
    render json: @post
  end

  def create
    post = Post.new(post_params)
    set_user && set_sub
    post.assign_attributes user_id: @user.id, sub_id: @sub.id

    if post.save
      render json: post, status: :created
    else
      render json: post.errors, status: :unprocessable_entity
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
    @post = Post.find(params[:id])
  end

  def set_user
    @user = User.find_by_name(params[:user_name]) || User.find(post_params[:user_id])
  end

  def set_sub
    @sub = Sub.find_by_name(params[:sub_name]) || Sub.find(post_params[:sub_id])
  end

  def post_params
    params.require(:post).permit(:user_id, :sub_id, :title, :url, :body)
  end
end

```

```bash
$ rspec
$ rubocop
```

```
$ rails c
> require_relative 'spec/support/factories'
> 4.times { FactoryBot.create :post }
> user = FactoryBot.create :user, name: 'reddituser'
> sub = FactoryBot.create :sub, name: 'redditsub'
> post = FactoryBot.create :post, user_id: user.id, sub_id: sub.id
> post.id # remember this, mine was 5
> quit
$ rails s
```

in another terminal

```bash
$ curl -X GET http://localhost:3000/users/reddituser/posts | jq
$ curl -X GET http://localhost:3000/users/reddituser/posts/5 | jq
$ curl -X PATCH -H Content-Type:application/json -H Accept:application/json http://localhost:3000/users/reddituser/posts/5 -d '{"post":{"title":"other title"}}' | jq
$ curl -X GET http://localhost:3000/users/reddituser/posts/5 | jq
$ curl -X DELETE http://localhost:3000/users/reddituser/posts/5 | jq
$ curl -X GET http://localhost:3000/users/reddituser/posts/5 | jq
```

