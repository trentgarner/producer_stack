Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root 'application#home'  # Set this to your homepage or other desired controller/action

  get 'home', to: 'application#home'

  resources :users
  resources :blogs
  resources :beats

  resources :analyze, only: [:index] do
    collection do
      post 'upload'
    end
  end

  namespace :admin do 
    resources :users, only: [:index, :show, :edit, :update, :destroy]
    get 'dashboard', to: 'users#admin_dashboard'
  end

end
