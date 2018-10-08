#### Votes

```bash
$ rails g model vote user:belongs_to up:boolean voteable_id:integer voteable_type:string
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_vote_params
      post = create_post
      { user: post.user, voteable: post, up: true }
    end

    def create_vote(params = {})
      Vote.create default_vote_params.merge(params)
    end
  end
end

```

###### spec/model/vote_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'voteable' do
    it { should belong_to(:voteable) }
  end
end

```

###### app/models/vote.rb

```ruby
class Vote < ApplicationRecord
  belongs_to :user

  belongs_to :voteable, polymorphic: true
end

```

```bash
$ rspec
$ rubocop
```

##### User Vote Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'votes' do
    it { should have_many(:votes) }
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :votes

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Post Vote Association

###### spec/model/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'votes' do
    it { should have_many(:votes) }

    context 'on destroy' do
      it 'should destroy associated votes' do
        post = create_post
        _vote = create_vote voteable: post
        expect { post.destroy }.to change { Vote.count }.by(-1)
      end
    end
  end
end

```

###### app/models/post.rb

```ruby
class Post < ActiveRecord::Base
  ...

  has_many :votes, as: :voteable, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

##### Comment Vote Association

###### spec/model/comment_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Comment, type: :model do
  ...

  describe 'votes' do
    it { should have_many(:votes) }

    context 'on destroy' do
      it 'should destroy associated votes' do
        comment = create_comment
        _vote = create_vote voteable: comment
        expect { comment.destroy }.to change { Vote.count }.by(-1)
      end
    end
  end
end

```

###### app/models/comment.rb

```ruby
class Comment < ActiveRecord::Base
  ...

  has_many :votes, as: :voteable, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

