Rails.application.routes.draw do
  devise_for :users

  get 'home', to: 'application#home'

  root "application#router"

  resources :users 
  namespace :admin do 
    resources :users
  end

  resources :blogs 

end
