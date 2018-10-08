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

  describe 'active' do
    context 'on create' do
      it 'should be true' do
        expect(create_post.active).to be true
      end
    end
  end
end
