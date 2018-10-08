# Reset

```bash
$ rm -r reddit-clone
$ dropdb redditdevsdb
$ dropdb reddittestdb
$ dropuser redditapp
```

# Installs

TODO

# Setup

```bash
$ mkdir reddit-clone
$ cd reddit-clone
```

# Backend

## Setup

```bash
$ rails new backend --api -d postgresql
$ cd backend/
```

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

  # Use guard for automatically running tests
  gem 'guard-rspec'

  # Use rspec for testing
  gem 'rspec-rails'

  # Use shoulda-matchers for easy testing
  gem 'shoulda-matchers'

  # Use rubocop for static code analyzation
  gem 'rubocop'
end

# Use Devise for users
gem 'devise'

# Use figaro for environment variables
gem 'figaro'

# Use JWT for auth
gem 'jwt'

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
$ bundle exec guard init rspec
$ guard
```

###### Guardfile

```ruby
...

guard :rspec, cmd: 'bundle exec rspec' do
  ...

  watch(rails.controllers) do |m|
    [
      ...,
      rspec.spec.call("requests/#{m[1]}")
    ]
  end

  ...
end

```

```bash
$ touch .rubocop.yml
```

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
$ rails g devise:install
$ rm -r test/
$ rails g rspec:install
```

###### spec/rails_helper.rb

```ruby
...

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  ...
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

```

## Models

#### Users

```bash
$ rails g devise User
$ rails g migration AddNameToUsers name:string
$ rails db:migrate
$ mkdir spec/support
$ touch spec/support/generation_helper.rb
$ touch spec/support/validation_helper.rb
```

###### spec/rails_helper.rb

```ruby
...

RSpec.configure do |config|
  ...

  config.include Helpers::GenerationHelper, type: :model
end

...

```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    def default_user_params
      { name: 'user', email: 'user@user.com', password: 'change', password_confirmation: 'change' }
    end

    def create_user(params = {})
      User.create default_user_params.merge(params)
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::GenerationHelper, type: :model
end

```

###### spec/support/validation_helper.rb

```ruby
module Helpers
  module ValidationHelper
    def blank_values
      ['', ' ', "\n", "\r", "\t", "\f"]
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::ValidationHelper, type: :model
end

```

###### spec/model/user_spec.rb

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

###### app/model/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  VALID_NAME_REGEX = /\A[A-Za-z0-9_\-]+\Z/
  validates :name, presence: true, allow_blank: false, uniqueness: true,
                   format: { with: VALID_NAME_REGEX }, length: { minimum: 3, maximum: 20 }
end

```

```bash
$ rspec
$ rubocop
```

#### Subs

```bash
$ rails g model sub name:string
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_sub_params
      { name: 'politics' }
    end

    def create_sub(params = {})
      Sub.create default_sub_params.merge(params)
    end
  end
end

...

```

###### spec/model/sub_spec.rb

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

###### app/model/sub.rb

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

#### Posts

```bash
$ rails g model post user:belongs_to sub:belongs_to title:text url:string body:text active:boolean
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_post_params
      { user: create_user, sub: create_sub, title: 'Lorem ipsum', url: 'https://www.github.com' }
    end

    def create_post(params = {})
      Post.create default_post_params.merge(params)
    end
  end
end

...

```

###### spec/model/post_spec.rb

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

  describe 'active' do
    context 'on create' do
      it 'should be true' do
        expect(create_post.active).to be true
      end
    end
  end
end

```

###### app/model/post.rb

```ruby
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :sub

  validates :title, presence: true, allow_blank: false, length: { maximum: 256 }

  validates :body, length: { maximum: 10_000 }

  validates :url, uniqueness: true, format: { with: URI::DEFAULT_PARSER.make_regexp }

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

##### User Post Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'posts' do
    it { should have_many(:posts) }

    context 'on destroy' do
      it 'should deactivate associated posts' do
        post = create_post
        expect(post.active).to be true
        post.user.destroy
        post.reload
        expect(post.active).to be false
      end

      it 'should nullify self on associated posts' do
        post = create_post
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

##### Sub Post Association

###### spec/model/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  ...

  describe 'posts' do
    it { should have_many(:posts) }

    context 'on destroy' do
      it 'should destroy associated posts' do
        post = create_post
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

#### Comments

```bash
$ rails g model comment user:belongs_to content:text active:boolean commentable_id:integer commentable_type:string
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_comment_params
      post = create_post
      { user: post.user, commentable: post, content: 'Lorem ipsum dolor' }
    end

    def create_comment(params = {})
      Comment.create default_comment_params.merge(params)
    end
  end
end

...

```

###### spec/model/comment_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'commentable' do
    it { should belong_to(:commentable) }
  end

  describe 'content' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(10_000) }
    it { should_not allow_values(*blank_values).for(:content) }
  end

  describe 'comments' do
    it { should have_many(:comments) }

    context 'on destroy' do
      it 'should destroy associated comments' do
        comment = create_comment
        comment_child = create_comment(user: comment.user,
                                       commentable: comment,
                                       content: 'child comment')
        _comment_grandchild = create_comment(user: comment_child.user,
                                             commentable: comment_child,
                                             content: 'comment_child comment')
        expect { comment.destroy }.to change { Comment.count }.by(-3)
      end
    end
  end

  describe 'active' do
    context 'on create' do
      it 'should be true' do
        expect(create_comment.active).to be true
      end
    end
  end
end

```

###### app/model/comment.rb

```ruby
class Comment < ApplicationRecord
  belongs_to :user

  belongs_to :commentable, polymorphic: true

  validates :content, presence: true, allow_blank: false, length: { maximum: 10_000 }

  has_many :comments, as: :commentable, dependent: :destroy

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

##### User Comment Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'comments' do
    it { should have_many(:comments) }

    context 'on destroy' do
      it 'should deactivate associated comments' do
        comment = create_comment
        expect(comment.active).to be true
        comment.user.destroy
        comment.reload
        expect(comment.active).to be false
      end

      it 'should nullify self on associated comments' do
        comment = create_comment
        comment.user.destroy
        comment.reload
        expect(comment.user_id).to be_nil
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ApplicationRecord
  ...

  has_many :comments, dependent: :nullify
  before_destroy :deactivate_comments, prepend: true

  private

  ...

  def deactivate_comments
    comments.update_all(active: false)
  end
end

```

```bash
$ rspec
$ rubocop
```

##### Post Comment Association

###### spec/model/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'comments' do
    it { should have_many(:comments) }

    context 'on destroy' do
      it 'should destroy associated comments' do
        post = create_post
        _comment = create_comment user: post.user, commentable: post, content: 'comment'
        expect { post.destroy }.to change { Comment.count }.by(-1)
      end
    end
  end
end

```

###### app/models/post.rb

```ruby
class Post < ApplicationRecord
  ...

  has_many :comments, as: :commentable, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

#### Votes

```bash
$ rails g model vote user:belongs_to up:boolean voteable_id:integer voteable_type:string
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_vote_params
      post = create_post
      { user: post.user, voteable: post, up: true }
    end

    def create_vote(params = {})
      Vote.create default_vote_params.merge(params)
    end
  end
end

...

```

###### spec/model/vote_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'voteable' do
    it { should belong_to(:voteable) }
  end
end

```

###### app/models/vote.rb

```ruby
class Vote < ApplicationRecord
  belongs_to :user

  belongs_to :voteable, polymorphic: true
end

```

```bash
$ rspec
$ rubocop
```

##### User Vote Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'votes' do
    it { should have_many(:votes) }
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :votes

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Post Vote Association

###### spec/model/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'votes' do
    it { should have_many(:votes) }

    context 'on destroy' do
      it 'should destroy associated votes' do
        post = create_post
        _vote = create_vote voteable: post
        expect { post.destroy }.to change { Vote.count }.by(-1)
      end
    end
  end
end

```

###### app/models/post.rb

```ruby
class Post < ActiveRecord::Base
  ...

  has_many :votes, as: :voteable, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Comment Vote Association

###### spec/model/comment_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Comment, type: :model do
  ...

  describe 'votes' do
    it { should have_many(:votes) }

    context 'on destroy' do
      it 'should destroy associated votes' do
        comment = create_comment
        _vote = create_vote voteable: comment
        expect { comment.destroy }.to change { Vote.count }.by(-1)
      end
    end
  end
end

```

###### app/models/comment.rb

```ruby
class Comment < ActiveRecord::Base
  ...

  has_many :votes, as: :voteable, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

#### Favorites

```bash
$ rails g model favorite user:belongs_to post:belongs_to
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_favorite_params
      post = create_post
      { user: post.user, post: post }
    end

    def create_favorite(params = {})
      Favorite.create default_favorite_params.merge(params)
    end
  end
end

...

```

###### spec/model/favorite_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'post' do
    it { should belong_to(:post) }
  end
end

```

```bash
$ rspec
$ rubocop
```

##### User Favorite Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'favorites' do
    it { should have_many(:favorites) }

    context 'on destroy' do
      it 'should destroy associated favorites' do
        favorite = create_favorite
        expect { favorite.user.destroy }.to change { Favorite.count }.by(-1)
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :favorites, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Post Favorite Association

###### spec/model/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'favorites' do
    it { should have_many(:favorites) }

    context 'on destroy' do
      it 'should destroy associated favorites' do
        favorite = create_favorite
        expect { favorite.post.destroy }.to change { Favorite.count }.by(-1)
      end
    end
  end
end

```

###### app/models/post.rb

```ruby
class Post < ActiveRecord::Base
  ...

  has_many :favorites, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

#### Follows

```bash
$ rails g model follow user:belongs_to sub:belongs_to
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_follow_params
      { user: create_user, sub: create_sub }
    end

    def create_follow(params = {})
      Follow.create default_follow_params.merge(params)
    end
  end
end

...

```

###### spec/model/follow_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'sub' do
    it { should belong_to(:sub) }
  end
end

```

```bash
$ rspec
$ rubocop
```

##### User Follow Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'follows' do
    it { should have_many(:follows) }
    it { should have_many(:subscriptions).through(:follows).source(:sub) }

    context 'on destroy' do
      it 'should destroy associated follows' do
        follow = create_follow
        expect { follow.user.destroy }.to change { Follow.count }.by(-1)
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :follows, dependent: :destroy
  has_many :subscriptions, through: :follows, source: :sub

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Sub Follow Association

###### spec/model/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  ...

  describe 'follows' do
    it { should have_many(:follows) }
    it { should have_many(:subscribers).through(:follows).source(:user) }

    context 'on destroy' do
      it 'should destroy associated follows' do
        follow = create_follow
        expect { follow.sub.destroy }.to change { Follow.count }.by(-1)
      end
    end
  end
end

```

###### app/models/sub.rb

```ruby
class Sub < ActiveRecord::Base
  ...

  has_many :follows, dependent: :destroy
  has_many :subscribers, through: :follows, source: :user
end

```

```bash
$ rspec
$ rubocop
```

#### Assignments

```bash
$ rails g model role name:string
$ rails g model assignment user:belongs_to role:belongs_to
$ rails db:migrate
```

###### spec/rails_helper.rb

```ruby
...

RSpec.configure do |config|
  ...

  config.before(:suite) do
    Role.create name: 'admin'
  end
end

...

```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_assignment_params
      { user: create_user, role: Role.find_by_name('admin') }
    end

    def create_assignment(params = {})
      Assignment.create default_assignment_params.merge(params)
    end
  end
end

```

###### spec/model/role_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'role' do
    it { should belong_to(:role) }
  end
end

```

###### spec/model/role_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'name' do
    it { should have_readonly_attribute(:name) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should_not allow_values(*blank_values).for(:name) }
  end
end

```

###### app/models/role.rb

```ruby
class Role < ApplicationRecord
  attr_readonly :name
  validates :name, presence: true, allow_blank: false
  validates_uniqueness_of :name, case_sensitive: false
end

```

```bash
$ rspec
$ rubocop
```

##### User Assignment Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'assignments' do
    it { should have_many(:assignments) }
    it { should have_many(:roles).through(:assignments) }

    context 'on destroy' do
      it 'should destroy associated assignments' do
        user = create_user
        expect { user.destroy }.to change { Assignment.count }.by(-1)
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :assignments, dependent: :destroy
  has_many :roles, through: :assignments

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

admin stuff here

#### Moderations

```bash
$ rails g model rank level:string
$ rails g model moderation user:belongs_to sub:belongs_to rank:belongs_to
$ rails db:migrate
```

###### spec/rails_helper.rb

```ruby
...

RSpec.configure do |config|
  ...

  config.before(:suite) do
    ...

    Rank.create level: 'owner'
    Rank.create level: 'moderator'
  end
end

...

```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_moderation_params
      { user: create_user, sub: create_sub, rank: Rank.find_by_level('moderator') }
    end

    def create_moderation(params = {})
      Moderation.create default_moderation_params.merge(params)
    end
  end
end

```

###### spec/model/moderation_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Moderation, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'sub' do
    it { should belong_to(:sub) }
  end

  describe 'rank' do
    it { should belong_to(:rank) }
  end
end

```

###### spec/model/rank_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Rank, type: :model do
  describe 'level' do
    it { should have_readonly_attribute(:level) }
    it { should validate_presence_of(:level) }
    it { should validate_uniqueness_of(:level).case_insensitive }
    it { should_not allow_values(*blank_values).for(:level) }
  end
end

```

###### app/models/rank.rb

```ruby
class Rank < ApplicationRecord
  attr_readonly :level
  validates :level, presence: true, allow_blank: false
  validates_uniqueness_of :level, case_sensitive: false
end

```

```bash
$ rspec
$ rubocop
```

##### User Moderation Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'moderations' do
    it { should have_many(:moderations) }
    it { should have_many(:obligations).through(:moderations).source(:sub) }

    context 'on destroy' do
      it 'should destroy associated moderations' do
        moderation = create_moderation
        expect { moderation.user.destroy }.to change { Moderation.count }.by(-1)
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :moderations, dependent: :destroy
  has_many :obligations, through: :moderations, source: :sub

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Sub Moderation Association

###### spec/model/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  ...

  describe 'moderations' do
    it { should have_many(:moderations) }
    it { should have_many(:moderators).through(:moderations).source(:user) }

    context 'on destroy' do
      it 'should destroy associated moderations' do
        moderation = create_moderation
        expect { moderation.sub.destroy }.to change { Moderation.count }.by(-1)
      end
    end
  end
end

```

###### app/models/sub.rb

```ruby
class Sub < ActiveRecord::Base
  ...

  has_many :moderations, dependent: :destroy
  has_many :moderators, through: :moderations, source: :user
end

```

```bash
$ rspec
$ rubocop
```

## Controllers

<!--

###### test/test_helper.rb

```ruby
...

module ActionDispatch
  class IntegrationTest
    def get(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def post(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def patch(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def put(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def head(path, obj = {})
      super(path, intercept_obj(obj))
    end

    def delete(path, obj = {})
      super(path, intercept_obj(obj))
    end

    private

    def intercept_obj(obj)
      obj[:params] = obj[:params].to_json if obj[:params]
      obj[:headers] = { 'CONTENT_TYPE' => 'application/json' }.merge(obj[:headers]) if obj[:headers]
      obj
    end
  end
end

```

-->

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
  config.navigational_formats = [:json]

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

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe '#as_json' do
    it 'should have keys of name, posts, comments only' do
      keys = %w[name posts comments]
      user = create_user

      json_user = user.as_json

      keys.each { |key| expect(json_user).to have_key(key) }
      expect(json_user.keys.sort).to eq(keys.sort)
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ApplicationRecord
  ...

  def as_json(_options = {})
    post_includes = { only: %i[id title url] }
    comment_includes = { only: %i[id commentable_id content] }
    super only: :name, include: { posts: post_includes, comments: comment_includes }
  end

  private

  ...
end

```

#### Subs

```bash
$ rails g scaffold_controller Sub
$ rm spec/requests/subs_spec.rb
```

###### config/routes.rb

```ruby

```

###### spec/routing/subs_routing_spec.rb

```ruby

```

###### spec/controllers/subs_controller_spec.rb

```ruby

```

###### app/controllers/subs_controller.rb

```ruby

```

###### spec/model/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  ...

  describe '#as_json' do
    it 'should have keys of name, posts only' do
      keys = %w[name posts]
      sub = create_sub

      json_sub = sub.as_json

      keys.each { |key| expect(json_sub).to have_key(key) }
      expect(json_sub.keys.sort).to eq(keys.sort)
    end
  end
end

```

###### app/models/sub.rb

```ruby
class Sub < ApplicationRecord
  ...

  def as_json(_options = {})
    post_includes = { only: %i[id title url] }
    super only: :name, include: { posts: post_includes }
  end
end

```

#### Posts

```bash
$ rails g scaffold_controller Post
$ rm spec/requests/posts_spec.rb
```

###### config/routes.rb

```ruby

```

###### spec/routing/posts_routing_spec.rb

```ruby

```

###### spec/controllers/posts_controller_spec.rb

```ruby

```

###### app/controllers/posts_controller.rb

```ruby

```

###### spec/model/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe '#as_json' do
    it 'should have keys of title, url, body, active, comments only' do
      keys = %w[title url body active comments]
      post = create_post

      json_post = post.as_json

      keys.each { |key| expect(json_post).to have_key(key) }
      expect(json_post.keys.sort).to eq(keys.sort)
    end
  end
end

```

###### app/models/post.rb

```ruby
class Post < ApplicationRecord
  ...

  def as_json(_options = {})
    comment_includes = { only: %i[id user_id content] }
    super only: %i[title url body active], include: { comments: comment_includes }
  end

  private

  ...
end

```

#### Comments

```bash
$ rails g scaffold_controller Comment
$ rm spec/requests/comments_spec.rb
```

###### config/routes.rb

```ruby

```

###### spec/routing/comments_routing_spec.rb

```ruby

```

###### spec/controllers/comments_controller_spec.rb

```ruby

```

###### app/controllers/comments_controller.rb

```ruby

```

###### spec/model/comment_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Comment, type: :model do
  ...

  describe '#as_json' do
    it 'should have keys of content, active, comments only' do
      keys = %w[content active comments]
      comment = create_comment

      json_comment = comment.as_json

      keys.each { |key| expect(json_comment).to have_key(key) }
      expect(json_comment.keys.sort).to eq(keys.sort)
    end
  end
end

```

###### app/models/comment.rb

```ruby
class Comment < ApplicationRecord
  ...

  def as_json(_options = {})
    comment_includes = { only: %i[id user_id content] }
    super only: %i[content active], include: { comments: comment_includes }
  end

  private

  ...
end

```

#### Votes

```bash
$ rails g scaffold_controller Vote
$ rm spec/requests/votes_spec.rb
```

###### config/routes.rb

```ruby

```

###### spec/routing/votes_routing_spec.rb

```ruby

```

###### spec/controllers/votes_controller_spec.rb

```ruby

```

###### app/controllers/votes_controller.rb

```ruby

```

###### spec/model/vote_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Vote, type: :model do
  ...

  describe '#as_json' do
    it 'should have keys of up only' do
      keys = %w[up]
      vote = create_vote

      json_vote = vote.as_json

      keys.each { |key| expect(json_vote).to have_key(key) }
      expect(json_vote.keys.sort).to eq(keys.sort)
    end
  end
end

```

###### app/models/vote.rb

```ruby
class Vote < ApplicationRecord
  ...

  def as_json(_options = {})
    super only: %i[up]
  end
end

```

#### Favorites

```bash
$ rails g scaffold_controller Favorite
$ rm spec/requests/favorites_spec.rb
```

###### config/routes.rb

```ruby

```

###### spec/routing/favorites_routing_spec.rb

```ruby

```

###### spec/controllers/favorites_controller_spec.rb

```ruby

```

###### app/controllers/favorites_controller.rb

```ruby

```

###### spec/model/favorite_spec.rb

```ruby

```

###### app/models/favorite.rb

```ruby

```

#### Follows

```bash
$ rails g scaffold_controller Follow
$ rm spec/requests/follows_spec.rb
```

###### config/routes.rb

```ruby

```

###### spec/routing/follows_routing_spec.rb

```ruby

```

###### spec/controllers/follows_controller_spec.rb

```ruby

```

###### app/controllers/follows_controller.rb

```ruby

```

###### spec/model/follow_spec.rb

```ruby

```

###### app/models/follow.rb

```ruby

```

