require 'rails_helper'

RSpec.describe SubsController, type: :routing do
  describe 'routing' do
    let(:existing_sub) { create :sub }
    let(:collection_route) { '/subs' }
    let(:member_route) { "/subs/#{existing_sub.name}" }
    let(:member_params) { { name: existing_sub.name } }

    it 'routes to #index' do
      expect(get: collection_route).to route_to('subs#index')
    end

    it 'routes to #show' do
      expect(get: member_route).to route_to('subs#show', member_params)
    end

    it 'routes to #create' do
      expect(post: collection_route).to route_to('subs#create')
    end

    it 'routes to #update via PUT' do
      expect(put: member_route).to route_to('subs#update', member_params)
    end

    it 'routes to #update via PATCH' do
      expect(patch: member_route).to route_to('subs#update', member_params)
    end

    it 'routes to #destroy' do
      expect(delete: member_route).to route_to('subs#destroy', member_params)
    end
  end
end
