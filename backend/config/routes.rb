Rails.application.routes.draw do
  resources :users, param: :name
end
