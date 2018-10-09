require 'rails_helper'

RSpec.describe SubsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      index_request = { params: {} }
      get :index, index_request

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      sub = create :sub
      show_request = { params: { name: sub.to_param } }
      get :show, show_request

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested sub' do
        sub = build :sub
        sub_params = { name: sub.name }
        create_request = { params: { sub: sub_params } }

        expect { post :create, create_request }.to change { Sub.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(sub_url(Sub.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new sub' do
        sub = build :sub, name: ''
        sub_params = { name: sub.name }
        create_request = { params: { sub: sub_params } }

        post :create, create_request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested sub' do
        original_sub = create :sub
        sub = build :sub, name: 'other'
        sub_params = { name: sub.name }
        update_request = { params: { name: original_sub.to_param, sub: sub_params } }
        put :update, update_request

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        original_sub.reload
        assert_equal sub.name, original_sub.name
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the sub' do
        original_sub = create :sub
        sub = build :sub, name: ''
        sub_params = { name: sub.name }
        update_request = { params: { name: original_sub.to_param, sub: sub_params } }
        put :update, update_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested sub' do
      sub = create :sub
      destroy_request = { params: { name: sub.to_param } }

      expect { delete :destroy, destroy_request }.to change { Sub.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
