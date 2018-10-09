require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'to_param' do
    it 'overrides #to_param with name attribute' do
      user = create :user
      expect(user.to_param).to eq(user.name)
    end
  end

  describe 'name' do
    invalid_names = ['username!', 'username?', 'username*', 'username#', 'user name']
    valid_names = ['username', 'user-name', 'user_name', 'user1name', '_username_', '-username-',
                   '1username1', 'USERNAME']

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(20) }
    it { should_not allow_values(*blank_values).for(:name) }
    it { should_not allow_values(*invalid_names).for(:name) }
    it { should allow_values(*valid_names).for(:name) }
  end

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
