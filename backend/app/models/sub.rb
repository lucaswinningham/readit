class Sub < ApplicationRecord
  VALID_NAME_REGEX = /\A[a-zA-Z0-9]+\Z/
  validates :name, presence: true, allow_blank: false, format: { with: VALID_NAME_REGEX },
                   length: { minimum: 3, maximum: 21 }
  validates_uniqueness_of :name, case_sensitive: false

  has_many :posts, dependent: :destroy

  def to_param
    name
  end
end
