require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  describe 'routing' do
    let(:existing_post) { create :post }

    describe 'users concerns' do
      let(:collection_route) { "/users/#{existing_post.user.name}/posts" }
      let(:member_route) { "/users/#{existing_post.user.name}/posts/#{existing_post.id}" }
      let(:collection_params) { { user_name: existing_post.user.name } }
      let(:member_params) { { user_name: existing_post.user.name, id: existing_post.to_param } }

      it 'routes to #index' do
        expect(get: collection_route).to route_to('posts#index', collection_params)
      end
  
      it 'routes to #show' do
        expect(get: member_route).to route_to('posts#show', member_params)
      end
  
      it 'routes to #create' do
        expect(post: collection_route).to route_to('posts#create', collection_params)
      end
  
      it 'routes to #update via PUT' do
        expect(put: member_route).to route_to('posts#update', member_params)
      end
  
      it 'routes to #update via PATCH' do
        expect(patch: member_route).to route_to('posts#update', member_params)
      end
  
      it 'routes to #destroy' do
        expect(delete: member_route).to route_to('posts#destroy', member_params)
      end
    end

    describe 'subs concerns' do
      let(:collection_route) { "/subs/#{existing_post.sub.name}/posts" }
      let(:member_route) { "/subs/#{existing_post.sub.name}/posts/#{existing_post.id}" }
      let(:collection_params) { { sub_name: existing_post.sub.name } }
      let(:member_params) { { sub_name: existing_post.sub.name, id: existing_post.to_param } }

      it 'routes to #index' do
        expect(get: collection_route).to route_to('posts#index', collection_params)
      end
  
      it 'routes to #show' do
        expect(get: member_route).to route_to('posts#show', member_params)
      end
  
      it 'routes to #create' do
        expect(post: collection_route).to route_to('posts#create', collection_params)
      end
  
      it 'routes to #update via PUT' do
        expect(put: member_route).to route_to('posts#update', member_params)
      end
  
      it 'routes to #update via PATCH' do
        expect(patch: member_route).to route_to('posts#update', member_params)
      end
  
      it 'routes to #destroy' do
        expect(delete: member_route).to route_to('posts#destroy', member_params)
      end
    end
  end
end
