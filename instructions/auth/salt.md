```bash
$ cd backend/
```

###### backend/Gemfile

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

```bash
$ rails g serializer Salt salt_string
```

<!-- figure out how to return user name instead of / in addition to, its id using the fast json api -->
###### app/serializers/salt_serializer.rb

```ruby
class SaltSerializer
  ...

  belongs_to :user
end

```

###### app/controllers/salts_controller.rb

```ruby
class SaltsController < ApplicationController
  before_action :set_user

  def show
    if @user
      render json: SaltSerializer.new(@user.salt)
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

```bash
$ rspec
$ rubocop
```

