Rails.application.routes.draw do
  devise_for :users, controller: {
    registrations: 'registrations'
  }

  root "application#router"

  get 'store', to: 'store#index'
  get 'home', to: 'application#home'

  resources :users 
  namespace :admin do 
    resources :users
  end

  resources :blogs
    
end
