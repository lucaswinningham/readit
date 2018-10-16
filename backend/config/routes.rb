Rails.application.routes.draw do
  concern(:postable) { resources :posts }
  concern(:saltable) { resource :salt, only: :show }
  concern(:nonceable) { resource :nonce, only: :create }

  user_concerns = %i[postable saltable nonceable]
  resources :users, param: :name, concerns: user_concerns

  sub_concerns = [:postable]
  resources :subs, param: :name, concerns: sub_concerns

  resources :sessions, only: :create
end
