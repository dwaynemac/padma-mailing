Mailing::Application.routes.draw do

  namespace :mercury do
     resources :images
  end
  mount Mercury::Engine => '/'
  devise_for :users do
    match "/login", :to => "devise/cas_sessions#new"
    match '/logout', to: "devise/cas_sessions#destroy"
  end

  namespace :api do
    namespace 'v0' do
      resources :scheduled_mails
      resources :imports, only: [:create, :show] do
        member do
          get :failed_rows # GET /api/v0/imports/:id/failed_rows
        end
      end
    end
  end

  namespace :mailchimp do

    resource :configuration do
      member do
        get :primary_list
      end
    end

    resources :lists, only: [:update] do
      member do
        get :segments
      end
    end

  end

  resources :scheduled_mails do
    collection do
      get :history, to: 'scheduled_mails#index', only_history: true
      get :pending, to: 'scheduled_mails#index', only_pending: true
    end
  end
  resources :triggers
  resources :templates do
    resources :attachments
    member do
      post 'deliver'
      put :mercury_update
    end
    collection { put :mercury_create }
  end
  resources :activities, only: [:destroy, :index]

  match 'message_door', to: 'message_door#catch'
  root to: 'templates#index'
end
