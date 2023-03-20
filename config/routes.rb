Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'home', to: 'application#home'

  root "application#router"

  resources :users 
  namespace :admin do 
    resources :users
  end


end
