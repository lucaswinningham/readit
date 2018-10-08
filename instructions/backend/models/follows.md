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

