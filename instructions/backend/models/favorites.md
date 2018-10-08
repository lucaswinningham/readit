#### Favorites

```bash
$ rails g model favorite user:belongs_to post:belongs_to
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_favorite_params
      post = create_post
      { user: post.user, post: post }
    end

    def create_favorite(params = {})
      Favorite.create default_favorite_params.merge(params)
    end
  end
end

```

###### spec/model/favorite_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Favorite, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'post' do
    it { should belong_to(:post) }
  end
end

```

```bash
$ rspec
$ rubocop
```

##### User Favorite Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'favorites' do
    it { should have_many(:favorites) }

    context 'on destroy' do
      it 'should destroy associated favorites' do
        favorite = create_favorite
        expect { favorite.user.destroy }.to change { Favorite.count }.by(-1)
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :favorites, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Post Favorite Association

###### spec/model/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'favorites' do
    it { should have_many(:favorites) }

    context 'on destroy' do
      it 'should destroy associated favorites' do
        favorite = create_favorite
        expect { favorite.post.destroy }.to change { Favorite.count }.by(-1)
      end
    end
  end
end

```

###### app/models/post.rb

```ruby
class Post < ActiveRecord::Base
  ...

  has_many :favorites, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

