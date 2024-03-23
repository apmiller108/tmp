require 'sidekiq/web'
require 'sidekiq_unique_jobs/web'
require 'sidekiq/cron/web'

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
    resources :memos
    resources :transcription_jobs, only: [] do
      resources :transcriptions, only: %i[index]
    end
    resources :transcription_downloads, param: :transcription_id, only: %i[show]
    resources :transcription_summaries, only: %i[create]
  end

  resources :generate_text_requests, only: %[create]
  resources :generate_image_requests, only: %i[create]

  resources :blobs, only: %i[show], param: :active_storage_blob_id
  resources :blob_details, only: %i[show], param: :active_storage_blob_id
  resources :blob_previews, only: %i[show], param: :active_storage_blob_id
end
