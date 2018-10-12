
* [Setup](setup/instructions.md)
* [Backend](#backend)
  * [Models](#backend-models)
    * [Users](#backend-user-model)
    * [Subs](#backend-sub-model)
    * [Posts](#backend-post-model)
  * [Controllers](#backend-controllers)
    * [Users](#backend-users-controller)
    * [Subs](#backend-subs-controller)
    * [Posts](#backend-posts-controller)

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

#### Backend User Model

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

#### Backend Sub Model

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

#### Backend Post Model

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

  validates :url, uniqueness: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
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

##### User Post Association

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

##### Sub Post Association

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

