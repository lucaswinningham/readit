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

