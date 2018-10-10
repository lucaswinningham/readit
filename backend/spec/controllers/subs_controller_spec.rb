require 'rails_helper'

RSpec.describe SubsController, type: :controller do
  let(:created_sub) { create :sub }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      params = { name: created_sub.to_param }
      get :show, params: params

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested sub' do
        new_sub = build :sub
        params = { sub: new_sub.as_json }

        expect { post :create, params: params }.to change { Sub.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(sub_url(Sub.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new sub' do
        new_sub = build :sub, name: ''
        params = { sub: new_sub.as_json }
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested sub' do
        sub_patch = build :sub, name: 'other'
        params = { name: created_sub.to_param, sub: sub_patch.as_json }
        put :update, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        created_sub.reload
        assert_equal sub_patch.name, created_sub.name
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the sub' do
        sub_patch = build :sub, name: ''
        params = { name: created_sub.to_param, sub: sub_patch.as_json }
        put :update, params: params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested sub' do
      params = { name: created_sub.to_param }

      expect { delete :destroy, params: params }.to change { Sub.count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
