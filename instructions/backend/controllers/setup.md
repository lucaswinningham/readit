###### Gemfile

```ruby
...

# Use Netflix's serializers
gem 'fast_jsonapi'

```

```bash
$ bundle
```

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

    config.eager_load_paths << Rails.root.join('app/serializers')
  end
end

```

<!-- factory setup stuff -->

