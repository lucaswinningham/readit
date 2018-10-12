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

