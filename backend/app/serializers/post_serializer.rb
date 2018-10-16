class PostSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :url, :body, :active
  belongs_to :user
  belongs_to :sub
end
