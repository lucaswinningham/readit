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

