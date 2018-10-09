require 'rails_helper'

RSpec.describe UsersController, type: :controller do
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
      existing_user = create :user
      show_request = { params: { name: existing_user.to_param } }
      get :show, show_request

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json')
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns a success response and creates the requested user' do
        new_user = build :user
        user_params = { name: new_user.name, email: new_user.email }
        create_request = { params: { user: user_params } }

        expect { post :create, create_request }.to change { User.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(user_url(User.last))
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new user' do
        new_user = build :user, name: '', email: ''
        user_params = { name: new_user.name, email: new_user.email }
        create_request = { params: { user: user_params } }

        post :create, create_request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'returns a success response and updates the requested user' do
        existing_user = create :user
        user_updated = build :user, name: 'other', email: 'other@email.com'
        user_params = { name: user_updated.name, email: user_updated.email }
        update_request = { params: { name: existing_user.to_param, user: user_params } }
        put :update, update_request

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')

        existing_user.reload
        assert_equal user_updated.name, existing_user.name
        assert_equal user_updated.email, existing_user.email
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the user' do
        existing_user = create :user
        user_updated = build :user, name: '', email: ''
        user_params = { name: user_updated.name, email: user_updated.email }
        update_request = { params: { name: existing_user.to_param, user: user_params } }
        put :update, update_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      existing_user = create :user
      destroy_request = { params: { name: existing_user.to_param } }

      expect { delete :destroy, destroy_request }.to change { User.count }.by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
