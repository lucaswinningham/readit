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
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the new post' do
          new_post = build :post, title: '', url: ''
          params = { user_name: new_post.user.name, post: new_post.as_json }
          post :create, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        it 'returns a success response and updates the requested post' do
          post_patch = build :post, title: 'other', url: 'http://www.other.com', body: 'body'
          user_name = created_post.user.name
          id = created_post.to_param
          params = { user_name: user_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')

          created_post.reload
          assert_equal post_patch.title, created_post.title
          assert_equal post_patch.url, created_post.url
          assert_equal post_patch.body, created_post.body
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the post' do
          post_patch = build :post, title: '', url: ''
          user_name = created_post.user.name
          id = created_post.to_param
          params = { user_name: user_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested post' do
        params = { user_name: created_post.user.name, id: created_post.to_param }

        expect { delete :destroy, params: params }.to change { Post.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'subs concerns' do
    describe 'GET #index' do
      it 'returns a success response' do
        params = { sub_name: create(:sub).name }
        get :index, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        params = { sub_name: created_post.sub.name, id: created_post.to_param }
        get :show, params: params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'returns a success response and creates the requested post' do
          new_post = build :post
          params = { sub_name: new_post.sub.name, post: new_post.as_json }

          expect { post :create, params: params }.to change { Post.count }.by(1)

          expect(response).to have_http_status(:created)
          expect(response.content_type).to eq('application/json')
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the new post' do
          new_post = build :post, title: '', url: ''
          params = { sub_name: new_post.sub.name, post: new_post.as_json }
          post :create, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        it 'returns a success response and updates the requested post' do
          post_patch = build :post, title: 'other', url: 'http://www.other.com', body: 'body'
          sub_name = created_post.sub.name
          id = created_post.to_param
          params = { sub_name: sub_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')

          created_post.reload
          assert_equal post_patch.title, created_post.title
          assert_equal post_patch.url, created_post.url
          assert_equal post_patch.body, created_post.body
        end
      end

      context 'with invalid params' do
        it 'renders a JSON response with errors for the post' do
          post_patch = build :post, title: '', url: ''
          sub_name = created_post.sub.name
          id = created_post.to_param
          params = { sub_name: sub_name, id: id, post: post_patch.as_json }
          put :update, params: params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested post' do
        params = { sub_name: created_post.sub.name, id: created_post.to_param }

        expect { delete :destroy, params: params }.to change { Post.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
