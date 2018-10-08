module Helpers
  module GenerationHelper
    def default_user_params
      { name: 'user', email: 'user@user.com' }
    end

    def create_user(params = {})
      User.create default_user_params.merge(params)
    end

    def default_sub_params
      { name: 'politics' }
    end

    def create_sub(params = {})
      Sub.create default_sub_params.merge(params)
    end

    def default_post_params
      { user: create_user, sub: create_sub, title: 'Lorem ipsum', url: 'https://www.github.com' }
    end

    def create_post(params = {})
      Post.create default_post_params.merge(params)
    end
  end
end
