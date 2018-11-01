class SessionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :user_name, :token
end
