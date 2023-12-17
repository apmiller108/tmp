require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  devise_scope :user do
    authenticated :user do
      root 'users#show', as: :authenticated_root
    end

    unauthenticated do
      root 'users/registrations#new'
    end
  end

  # Require authentication via devise and current_user be developer to view Sidekiq Web UI
  authenticate :user, ->(user) { user.developer? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :users, only: %i[show] do
    resources :messages
  end
end
