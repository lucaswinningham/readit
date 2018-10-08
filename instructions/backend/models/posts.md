#### Posts

```bash
$ rails g model post user:belongs_to sub:belongs_to title:text url:string body:text active:boolean
$ rails db:migrate
```

###### spec/models/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'user' do
    it { should belong_to(:user) }
  end

  describe 'sub' do
    it { should belong_to(:sub) }
  end

  describe 'title' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(256) }
    it { should_not allow_values(*blank_values).for(:title) }
  end

  describe 'body' do
    it { should validate_length_of(:body).is_at_most(10_000) }
  end

  describe 'url' do
    valid_urls = [
      'http://foo.com/blah_blah',
      'http://foo.com/blah_blah/',
      'http://www.example.com/wpstyle/?p=364',
      'https://www.example.com/foo/?bar=baz&inga=42&quux',
      'http://userid:password@example.com:8080',
      'http://userid:password@example.com:8080/',
      'http://userid@example.com',
      'http://userid@example.com/',
      'http://userid@example.com:8080',
      'http://userid@example.com:8080/',
      'http://userid:password@example.com',
      'http://userid:password@example.com/',
      'http://142.42.1.1/',
      'http://142.42.1.1:8080/',
      'http://code.google.com/events/#&product=browser',
      'http://j.mp',
      'http://foo.bar/?q=Test%20URL-encoded%20stuff',
      'http://1337.net',
      'http://a.b-c.de'
    ]
    invalid_urls = ['//', '//a', '///a', '///', 'foo.com', ':// should fail']

    it { should validate_uniqueness_of(:url) }
    it { should_not allow_values(*invalid_urls).for(:url) }
    it { should allow_values(*valid_urls).for(:url) }
  end
end

```

###### app/models/post.rb

```ruby
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :sub

  validates :title, presence: true, allow_blank: false, length: { maximum: 256 }

  validates :body, length: { maximum: 10_000 }

  validates :url, uniqueness: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
end

```

```bash
$ rspec
$ rubocop
```

###### spec/models/post_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  ...

  describe 'active' do
    context 'on create' do
      it 'should be true' do
        expect(create(:post).active).to be true
      end
    end
  end
end

```

###### Gemfile

```ruby
...

#
# Added
#

group :development, :test do
  ...

  # Use Factory Bot for test fixtures
  gem 'factory_bot'
end

...
```

```bash
$ bundle
```

###### spec/rails_helper.rb

```ruby
...

RSpec.configure do |config|
  ...

  config.include FactoryBot::Syntax::Methods
end

...
```

```bash
$ touch spec/support/factories.rb
```

###### spec/support/factories.rb

```ruby
FactoryBot.define do
  factory :user do
    name { 'goat' }
    email { 'goat@email.com' }
  end

  factory :sub do
    name { 'funny' }
  end

  factory :post do
    user
    sub
    title { 'Lorem ipsum' }
    url { 'https://www.github.com' }
  end
end

```

###### app/models/post.rb

```ruby
class Post < ApplicationRecord
  ...

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

##### User Post Association

###### spec/models/user_spec.rb

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  ...

  describe 'posts' do
    it { should have_many(:posts) }

    context 'on destroy' do
      it 'should deactivate associated posts' do
        post = create(:post)
        expect(post.active).to be true
        post.user.destroy
        post.reload
        expect(post.active).to be false
      end

      it 'should nullify self on associated posts' do
        post = create(:post)
        post.user.destroy
        post.reload
        expect(post.user_id).to be_nil
      end
    end
  end
end

```

###### app/models/user.rb

```ruby
class User < ActiveRecord::Base
  ...

  has_many :posts, dependent: :nullify
  before_destroy :deactivate_posts, prepend: true

  private

  def deactivate_posts
    posts.update_all(active: false)
  end
end

```

```bash
$ rspec
$ rubocop
```

##### Sub Post Association

###### spec/models/sub_spec.rb

```ruby
require 'rails_helper'

RSpec.describe Sub, type: :model do
  ...

  describe 'posts' do
    it { should have_many(:posts) }

    context 'on destroy' do
      it 'should destroy associated posts' do
        post = create(:post)
        expect { post.sub.destroy }.to change { Post.count }.by(-1)
      end
    end
  end
end

```

###### app/models/sub.rb

```ruby
class Sub < ApplicationRecord
  ...

  has_many :posts, dependent: :destroy
end

```

```bash
$ rspec
$ rubocop
```

