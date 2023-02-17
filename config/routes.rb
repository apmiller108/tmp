Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  root "items#index"

  resources :items, only: %i[index]
end
