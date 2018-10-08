module Helpers
  module GenerationHelper
    def default_user_params
      { name: 'user', email: 'user@user.com', password: 'change', password_confirmation: 'change' }
    end

    def create_user(params = {})
      User.create default_user_params.merge(params)
    end
  end
end
