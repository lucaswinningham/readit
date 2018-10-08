#### Nonces

```bash
$ rails g model Nonce user:belongs_to nonce_string:string expiration_at:datetime
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_nonce_params
      { user: create_user, nonce_string: '$2a$10$RandomlyGeneratedNonce.', expiration_at: FILL_IN }
    end

    def create_nonce(params = {})
      Nonce.create default_nonce_params.merge(params)
    end
  end
end

...

```

###### spec/model/nonce_spec.rb

###### app/model/nonce.rb

```ruby
class Nonce < ApplicationRecord
  belongs_to :user

  validates :nonce_string, presence: true, allow_blank: false, length: { minimum: 128, maximum: 128 }

  def self.generate_nonce
    Digest::SHA2.new(512).hexdigest(SecureRandom.hex)
  end
end

```

###### spec/model/user_spec.rb

###### app/model/user.rb

```ruby
class User < ApplicationRecord
  ...

  has_one :nonce, dependent: :destroy

  ...
end

```

