class SaltsController < ApplicationController
  before_action :set_user

  def show
    if @user
      # render json: SaltShowSerializer.new(@user.salt)
      render json: @user.salt
    else
      salt = Salt.new(salt_string: Salt.generate_salt)
      render json: SaltSerializer.new(salt)
    end
  end

  private

  def set_user
    @user = User.find_by_name params[:user_name]
  end
end
