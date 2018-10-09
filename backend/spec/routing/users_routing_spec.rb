require 'rails_helper'

RSpec.describe UsersController, type: :routing do
  describe 'routing' do
    let(:user) { create :user }

    it 'routes to #index' do
      expect(get: '/users').to route_to('users#index')
    end

    it 'routes to #show' do
      expect(get: "/users/#{user.name}").to route_to('users#show', name: user.name)
    end

    it 'routes to #create' do
      expect(post: '/users').to route_to('users#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/users/#{user.name}").to route_to('users#update', name: user.name)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/users/#{user.name}").to route_to('users#update', name: user.name)
    end

    it 'routes to #destroy' do
      expect(delete: "/users/#{user.name}").to route_to('users#destroy', name: user.name)
    end
  end
end
