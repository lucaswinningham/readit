class Post < ApplicationRecord
  belongs_to :user
  belongs_to :sub

  validates :title, presence: true, allow_blank: false, length: { maximum: 256 }

  validates :body, length: { maximum: 10_000 }

  validates :url, uniqueness: true, format: { with: URI::regexp }

  before_create :activate

  private

  def activate
    self.active = true
  end
end
