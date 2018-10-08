#### Comments

```bash
$ rails g model comment user:belongs_to content:text active:boolean commentable_id:integer commentable_type:string
$ rails db:migrate
```

###### spec/support/generation_helper.rb

```ruby
module Helpers
  module GenerationHelper
    ...

    def default_comment_params
      post = create_post
      { user: post.user, commentable: post, content: 'Lorem ipsum dolor' }
    end

    def create_comment(params = {})
      Comment.create default_comment_params.merge(params)
    end
  end
end

```

###### spec/model/comment_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'commentable' do
    it { should belong_to(:commentable) }
  end

  describe 'content' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(10_000) }
    it { should_not allow_values(*blank_values).for(:content) }
  end

  describe 'comments' do
    it { should have_many(:comments) }

    context 'on destroy' do
      it 'should destroy associated comments' do
        comment = create_comment
        comment_child = create_comment(user: comment.user,
                                       commentable: comment,
                                       content: 'child comment')
        _comment_grandchild = create_comment(user: comment_child.user,
                                             commentable: comment_child,
                                             content: 'comment_child comment')
        expect { comment.destroy }.to change { Comment.count }.by(-3)
      end
    end
  end

  describe 'active' do
    context 'on create' do
      it 'should be true' do
        expect(create_comment.active).to be true
      end
    end
  end
end

```

###### app/model/comment.rb

```ruby
class Comment < ApplicationRecord
  belongs_to :user

  belongs_to :commentable, polymorphic: true

  validates :content, presence: true, allow_blank: false, length: { maximum: 10_000 }

  has_many :comments, as: :commentable, dependent: :destroy

  before_create :activate

  private

  def activate
    self.active = true
  end
end

```

```bash
$ rspec
$ rubocop
```

##### User Comment Association

###### spec/model/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'comments' do
    it { should have_many(:comments) }

    context 'on destroy' do
      it 'should deactivate associated comments' do
        comment = create_comment
        expect(comment.active).to be true
        comment.user.destroy
        comment.reload
        expect(comment.active).to be false
      end

      it 'should nullify self on associated comments' do
        comment = create_comment
        comment.user.destroy
        comment.reload
        expect(comment.user_id).to be_nil
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ApplicationRecord
  ...

  has_many :comments, dependent: :nullify
  before_destroy :deactivate_comments, prepend: true

  private

  ...

  def deactivate_comments
    comments.update_all(active: false)
  end
end

```

```bash
$ rspec
$ rubocop
```

##### Post Comment Association

###### spec/model/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'comments' do
    it { should have_many(:comments) }

    context 'on destroy' do
      it 'should destroy associated comments' do
        post = create_post
        _comment = create_comment user: post.user, commentable: post, content: 'comment'
        expect { post.destroy }.to change { Comment.count }.by(-1)
      end
    end
  end
end

```

###### app/models/post.rb

```ruby
class Post < ApplicationRecord
  ...

  has_many :comments, as: :commentable, dependent: :destroy

  private

  ...
end

```

```bash
$ rspec
$ rubocop
```

