
* [Setup](#setup)
* [Backend](#backend)
  * [Models](#backend-models)
    * [Users](#backend-user-model)
    * [Subs](#backend-sub-model)
    * [Posts](#backend-post-model)
      * [User Association](#backend-user-post-association)
      * [Sub Association](#backend-sub-post-association)
  * [Controllers](#backend-controllers)
    * [Users](#backend-users-controller)
    * [Subs](#backend-subs-controller)
    * [Posts](#backend-posts-controller)
* [Auth](#auth)

# Reset

```bash
$ rm -r reddit-clone
$ dropdb redditdevsdb
$ dropdb reddittestdb
$ dropuser redditapp
```

# Installs

TODO: FILL OUT

```bash
brew install jq
```

# Setup

```bash
$ mkdir reddit-clone
$ cd reddit-clone
```

# Backend

```bash
$ rails new backend --api --database=postgresql --skip-test
$ cd backend/
```

<!-- add to this as you go through the work, not just all at once in the beginning -->

###### Gemfile

```ruby
...

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

...

#
# Added
#

group :development, :test do
  # Use awesome print for readability
  gem 'awesome_print'

  # Use rubocop for static code analyzation
  gem 'rubocop'
end

# Use figaro for environment variables
gem 'figaro'

```

```bash
$ bundle
```

###### config/initializers/cors.rb

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '*',
    headers: :any,
    expose:  ['access-token', 'expiry', 'token-type', 'uid', 'client'],
    methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end

```

```bash
$ touch .rubocop.yml
```

<!-- don't add all files, add as you go i.e. Guardfile doesn't exist yet -->

###### .rubocop.yml

```yaml
AllCops:
  Exclude:
    - 'Rakefile'
    - 'Gemfile'
    - 'Guardfile'
    - 'bin/*'
    - 'config/environments/*'
    - 'config/initializers/*'
    - 'config/application.rb'
    - 'config/puma.rb'
    - 'config/spring.rb'
    - 'db/migrate/*'
    - 'db/schema.rb'
    - 'db/seeds.rb'
    - 'spec/*_helper.rb'
Documentation:
  Enabled: false
Metrics/BlockLength:
  Exclude:
    - 'spec/**/*_spec.rb'
Metrics/LineLength:
  Max: 100
Metrics/MethodLength:
  Max: 15

```

```bash
$ rubocop
```

```bash
$ bundle exec figaro install
```

###### config/application.yml

```yaml
DB_ROLE_NAME: redditapp

DEVS_DB_NAME: redditdevsdb
DEVS_DB_PASS: devs

TEST_DB_NAME: reddittestdb
TEST_DB_PASS: test

PROD_DB_NAME: redditproddb
PROD_DB_PASS: prod

```

###### config/database.yml

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV.fetch("DB_ROLE_NAME") %>
  timeout: 5000

development:
  <<: *default
  database: <%= ENV['DEVS_DB_NAME'] %>
  password: <%= ENV['DEVS_DB_PASS'] %>

test:
  <<: *default
  database: <%= ENV['TEST_DB_NAME'] %>
  password: <%= ENV['TEST_DB_PASS'] %>

production:
  <<: *default
  database: prod_db
  username: <%= ENV['PROD_DB_NAME'] %>
  password: <%= ENV['PROD_DB_PASS'] %>

```

```bash
$ createuser -d redditapp
$ rails db:create
```

## Test Setup

###### Gemfile

```ruby
...

#
# Added
#

group :development, :test do
  ...

  # Use Faker for seeding the database
  gem 'faker'

  # Use guard for automatically running tests
  gem 'guard-rspec'

  # Use rspec for testing
  gem 'rspec-rails'

  # Use shoulda-matchers for easy testing
  gem 'shoulda-matchers'
end

...
```

```bash
$ bundle
$ bundle exec guard init rspec
$ rails g rspec:install
$ guard
```

###### spec/rails_helper.rb

```ruby
...

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

```

```bash
$ mkdir spec/support
$ touch spec/support/validation_helper.rb
```

###### spec/rails_helper.rb

```ruby
...

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  ...

  config.include Helpers::ValidationHelper, type: :model
end

...

```

<!-- add the urls from post? -->

###### spec/support/validation_helper.rb

```ruby
module Helpers
  module ValidationHelper
    def blank_values
      ['', ' ', "\n", "\r", "\t", "\f"]
    end
  end
end

```

## Backend Models

### Backend User Model

<!-- make sure factory bot is installed because it automatically creates a users factory file -->

```bash
$ rails g model user name:string email:string
$ rails db:migrate
```

###### spec/models/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'name' do
    invalid_names = ['username!', 'username?', 'username*', 'username#', 'user name']
    valid_names = ['username', 'user-name', 'user_name', 'user1name', '_username_', '-username-',
                   '1username1', 'USERNAME']

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(20) }
    it { should_not allow_values(*blank_values).for(:name) }
    it { should_not allow_values(*invalid_names).for(:name) }
    it { should allow_values(*valid_names).for(:name) }
  end
end

```

<!-- add email validations -->
###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[A-Za-z0-9_\-]+\Z/
  validates :name, presence: true, allow_blank: false, uniqueness: true,
                   format: { with: VALID_NAME_REGEX }, length: { minimum: 3, maximum: 20 }
end

```

```bash
$ rspec
$ rubocop
```

### Backend Sub Model

```bash
$ rails g model sub name:string
$ rails db:migrate
```

###### spec/models/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  describe 'name' do
    invalid_names = ['sub-name', 'sub_name', '_subname_', '-subname-', 'subname!', 'subname?',
                     'subname*', 'subname#']
    valid_names = %w[subname sub1name 1subname1 SUBNAME]

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(21) }
    it { should_not allow_values(*blank_values).for(:name) }
    it { should_not allow_values(*invalid_names).for(:name) }
    it { should allow_values(*valid_names).for(:name) }
  end
end

```

###### app/models/sub.rb

```ruby
class Sub < ApplicationRecord
  VALID_NAME_REGEX = /\A[a-zA-Z0-9]+\Z/
  validates :name, presence: true, allow_blank: false, format: { with: VALID_NAME_REGEX },
                   length: { minimum: 3, maximum: 21 }
  validates_uniqueness_of :name, case_sensitive: false
end

```

```bash
$ rspec
$ rubocop
```

### Backend Post Model

```bash
$ rails g model post user:belongs_to sub:belongs_to title:text url:string body:text active:boolean
$ rails db:migrate
```

###### spec/models/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'sub' do
    it { should belong_to(:sub) }
  end

  describe 'title' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(256) }
    it { should_not allow_values(*blank_values).for(:title) }
  end

  describe 'body' do
    it { should validate_length_of(:body).is_at_most(10_000) }
  end

  describe 'url' do
    valid_urls = [
      'http://foo.com/blah_blah',
      'http://foo.com/blah_blah/',
      'http://www.example.com/wpstyle/?p=364',
      'https://www.example.com/foo/?bar=baz&inga=42&quux',
      'http://userid:password@example.com:8080',
      'http://userid:password@example.com:8080/',
      'http://userid@example.com',
      'http://userid@example.com/',
      'http://userid@example.com:8080',
      'http://userid@example.com:8080/',
      'http://userid:password@example.com',
      'http://userid:password@example.com/',
      'http://142.42.1.1/',
      'http://142.42.1.1:8080/',
      'http://code.google.com/events/#&product=browser',
      'http://j.mp',
      'http://foo.bar/?q=Test%20URL-encoded%20stuff',
      'http://1337.net',
      'http://a.b-c.de'
    ]
    invalid_urls = ['//', '//a', '///a', '///', 'foo.com', ':// should fail']

    it { should validate_uniqueness_of(:url) }
    it { should_not allow_values(*invalid_urls).for(:url) }
    it { should allow_values(*valid_urls).for(:url) }
  end
end

```

###### app/models/post.rb

```ruby
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :sub

  validates :title, presence: true, allow_blank: false, length: { maximum: 256 }

  validates :body, length: { maximum: 10_000 }

  validates :url, uniqueness: true, format: { with: URI::regexp }
end

```

```bash
$ rspec
$ rubocop
```

###### spec/models/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'active' do
    context 'on create' do
      it 'should be true' do
        post = create :post
        expect(post.active).to be true
      end
    end
  end
end

```

###### Gemfile

```ruby
...

#
# Added
#

group :development, :test do
  ...

  # Use Factory Bot for test fixtures
  gem 'factory_bot_rails'
end

...
```

```bash
$ bundle
```

###### spec/rails_helper.rb

```ruby
...

RSpec.configure do |config|
  ...

  config.include FactoryBot::Syntax::Methods
end

...
```

```bash
$ touch spec/support/factories.rb
```

###### spec/support/factories.rb

```ruby
FactoryBot.define do
  factory :user do
    sequence(:name) { Faker::Internet.unique.username(3..20, %w[_ -]) }
    sequence(:email) { Faker::Internet.unique.safe_email }
  end

  factory :sub do
    sequence(:name) { Faker::Internet.unique.username(3..21, ['']) }
  end

  factory :post do
    user
    sub
    title { Faker::Lorem.sentence }
    url { Faker::Internet.unique.url }
  end
end

```

###### app/models/post.rb

```ruby
class Post < ApplicationRecord
  ...

  before_create :activate

  private

  def activate
    self.active = true
  end
end

```

```bash
$ rspec
$ rubocop
```

#### Backend User Post Association

###### spec/models/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'posts' do
    it { should have_many(:posts) }

    context 'on destroy' do
      it 'should deactivate associated posts' do
        post = create :post
        expect(post.active).to be true
        post.user.destroy
        post.reload
        expect(post.active).to be false
      end

      it 'should nullify self on associated posts' do
        post = create :post
        post.user.destroy
        post.reload
        expect(post.user_id).to be_nil
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :posts, dependent: :nullify
  before_destroy :deactivate_posts, prepend: true

  private

  def deactivate_posts
    posts.update_all(active: false)
  end
end

```

```bash
$ rspec
$ rubocop
```

#### Backend Sub Post Association

###### spec/models/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  ...

  describe 'posts' do
    it { should have_many(:posts) }

    context 'on destroy' do
      it 'should destroy associated posts' do
        post = create :post
        expect { post.sub.destroy }.to change { Post.count }.by(-1)
      end
    end
  end
end

```

###### app/models/sub.rb

```ruby
class Sub < ApplicationRecord
  ...

  has_many :posts, dependent: :destroy
end

```

```bash
$ rspec
$ rubocop
```

## Backend Controllers

###### config/application.rb

```ruby
...

module Backend
  class Application < Rails::Application
    ...

    #
    # Added
    #

    config.generators do |g|
      g.test_framework :rspec, request_specs: false
    end
  end
end

```

<!-- factory setup stuff -->

###### Gemfile

```ruby
...

# Use Netflix's serializers
gem 'fast_jsonapi'

```

### Backend Users Controller

```bash
$ rails g scaffold_controller user
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

### Backend Subs Controller

```bash
$ rails g scaffold_controller sub
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

### Backend Posts Controller

```bash
$ rails g scaffold_controller post
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

# Auth

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

    # Added

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

