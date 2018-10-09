require 'rails_helper'

RSpec.describe PostsController, type: :routing do
  describe 'routing' do
    let(:post) { create :post }

    it 'routes to #index' do
      route = "/users/#{post.user.name}/posts"
      params = { user_name: post.user.name }
      expect(get: route).to route_to('posts#index', params)

      route = "/subs/#{post.sub.name}/posts"
      params = { sub_name: post.sub.name }
      expect(get: route).to route_to('posts#index', params)
    end

    it 'routes to #show' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(get: route).to route_to('posts#show', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(get: route).to route_to('posts#show', params)
    end

    it 'routes to #create' do
      route = "/users/#{post.user.name}/posts"
      params = { user_name: post.user.name }
      expect(post: route).to route_to('posts#create', params)

      route = "/subs/#{post.sub.name}/posts"
      params = { sub_name: post.sub.name }
      expect(post: route).to route_to('posts#create', params)
    end

    it 'routes to #update via PUT' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(put: route).to route_to('posts#update', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(put: route).to route_to('posts#update', params)
    end

    it 'routes to #update via PATCH' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(patch: route).to route_to('posts#update', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(patch: route).to route_to('posts#update', params)
    end

    it 'routes to #destroy' do
      route = "/users/#{post.user.name}/posts/#{post.id}"
      params = { user_name: post.user.name, id: post.to_param }
      expect(delete: route).to route_to('posts#destroy', params)

      route = "/subs/#{post.sub.name}/posts/#{post.id}"
      params = { sub_name: post.sub.name, id: post.to_param }
      expect(delete: route).to route_to('posts#destroy', params)
    end
  end
end
