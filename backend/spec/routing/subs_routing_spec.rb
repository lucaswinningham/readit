require 'rails_helper'

RSpec.describe SubsController, type: :routing do
  describe 'routing' do
    let(:sub) { create :sub }

    it 'routes to #index' do
      expect(get: '/subs').to route_to('subs#index')
    end

    it 'routes to #show' do
      expect(get: "/subs/#{sub.name}").to route_to('subs#show', name: sub.name)
    end

    it 'routes to #create' do
      expect(post: '/subs').to route_to('subs#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/subs/#{sub.name}").to route_to('subs#update', name: sub.name)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/subs/#{sub.name}").to route_to('subs#update', name: sub.name)
    end

    it 'routes to #destroy' do
      expect(delete: "/subs/#{sub.name}").to route_to('subs#destroy', name: sub.name)
    end
  end
end
