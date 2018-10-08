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

