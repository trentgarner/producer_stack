Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  

  root "application#router"

  get 'home', to: 'application#home'

  resources :users 
  namespace :admin do 
    get 'dashboard', to: 'users#admin_dashboard'
    
  end

  resources :blogs

  resources :beats

end
