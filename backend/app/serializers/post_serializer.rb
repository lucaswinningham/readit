class PostSerializer
  include FastJsonapi::ObjectSerializer
  attributes :title, :url, :body, :active
end
