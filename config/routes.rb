Rails.application.routes.draw do
  devise_for :users, controller: {
    registrations: 'registrations'
  }

  root "application#router"

  get 'home', to: 'application#home'

  resources :users 
  namespace :admin do 
    get 'dashboard', to: 'users#admin_dashboard'
    resources :users
  end

  resources :blogs

  resources :beats
    get 'stream_audio', to: 'beats#index'
    get 'stream_audio', to: 'beats#show'
    
end

