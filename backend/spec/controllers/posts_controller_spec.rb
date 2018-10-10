require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:created_post) { create :post }

  describe 'users concerns' do
    describe 'GET #index' do
      it 'returns a success response' do
        params = { user_name: create(:user).name }
        get :index, params: params
  
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end
  
    describe 'GET #show' do
      it 'returns a success response' do
        params = { user_name: created_post.user.name, id: created_post.to_param }
        get :show, params: params
  
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end
  
    describe 'POST #create' do
      context 'with valid params' do
        it 'returns a success response and creates the requested post' do
          new_post = build :post
          params = { user_name: new_post.user.name, post: new_post.as_json }
  
          expect { post :create, params: params }.to change { Post.count }.by(1)
  
          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json')
          expect(response.location).to eq(post_url(Post.last))
        end
      end
  
      # context 'with invalid params' do
      #   it 'renders a JSON response with errors for the new post' do
      #     new_post = build :post, name: ''
      #     params = { post: new_post.as_json }
      #     post :create, params: params
  
      #     expect(response).to have_http_status(:unprocessable_entity)
      #     expect(response.content_type).to eq('application/json')
      #   end
      # end
    end
  
    # describe 'PUT #update' do
    #   context 'with valid params' do
    #     it 'returns a success response and updates the requested post' do
    #       post_patch = build :post, name: 'other'
    #       params = { name: created_post.to_param, post: post_patch.as_json }
    #       put :update, params: params
  
    #       expect(response).to have_http_status(:ok)
    #       expect(response.content_type).to eq('application/json')
  
    #       created_post.reload
    #       assert_equal post_patch.name, created_post.name
    #     end
    #   end
  
    #   context 'with invalid params' do
    #     it 'renders a JSON response with errors for the post' do
    #       post_patch = build :post, name: ''
    #       params = { name: created_post.to_param, post: post_patch.as_json }
    #       put :update, params: params
  
    #       expect(response).to have_http_status(:unprocessable_entity)
    #       expect(response.content_type).to eq('application/json')
    #     end
    #   end
    # end
  
    # describe 'DELETE #destroy' do
    #   it 'destroys the requested post' do
    #     params = { name: created_post.to_param }
  
    #     expect { delete :destroy, params: params }.to change { Post.count }.by(-1)
  
    #     expect(response).to have_http_status(:no_content)
    #   end
    # end
  end
end
