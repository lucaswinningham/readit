require 'rails_helper'

RSpec.describe Sub, type: :model do
  describe 'name' do
    invalid_names = ['sub-name', 'sub_name', '_subname_', '-subname-', 'subname!', 'subname?',
                     'subname*', 'subname#']
    valid_names = %w[subname sub1name 1subname1 SUBNAME]

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(21) }
    it { should_not allow_values(*blank_values).for(:name) }
    it { should_not allow_values(*invalid_names).for(:name) }
    it { should allow_values(*valid_names).for(:name) }
  end

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
