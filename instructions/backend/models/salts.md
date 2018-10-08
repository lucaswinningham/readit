#### Salts

```bash
$ rails g model Salt user:belongs_to salt_string:string
$ rails db:migrate
```

###### Gemfile

```ruby
...

#
# Added
#

group :development, :test do
  ...
end

# Use BCrypt for hashing
gem 'bcrypt'

...

```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_salt_params
      { user: create_user, salt_string: '$2a$10$RandomlyGeneratedSalt.' }
    end

    def create_salt(params = {})
      Salt.create default_salt_params.merge(params)
    end
  end
end

...

```

###### spec/model/salt_spec.rb

###### app/model/salt.rb

```ruby
class Salt < ApplicationRecord
  belongs_to :user

  validates :salt_string, presence: true, allow_blank: false, length: { minimum: 29, maximum: 29 }

  def self.generate_salt
    BCrypt::Engine.generate_salt
  end
end

```

###### spec/model/user_spec.rb

###### app/model/user.rb

```ruby
class User < ApplicationRecord
  ...

  has_one :salt, dependent: :destroy

  ...
end

```

