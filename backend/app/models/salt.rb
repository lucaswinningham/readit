class Salt < ApplicationRecord
  belongs_to :user

  def self.generate_salt
    BCrypt::Engine.generate_salt
  end
end
