Mailing::Application.routes.draw do

  #  namespace :mercury do
  #   resources :images
  #end
  #mount Mercury::Engine => '/'

  devise_for :users do
    get "/login", :to => "sso_sessions#show"
    match '/logout', to: "sso_sessions#destroy", via: [:get, :delete]
  end
  resource :sso_session
  get "/login", :to => "sso_sessions#show"
  match '/logout', to: "sso_sessions#destroy", via: [:get, :delete]

  namespace :api do
    namespace 'v0' do
      resources :scheduled_mails
      resources :merges, only: [:create]
      resources :imports, only: [:create, :show] do
        member do
          get :failed_rows # GET /api/v0/imports/:id/failed_rows
        end
      end
      namespace 'mailchimp' do
        resources :lists do
          member do
            get :webhooks
            post :webhooks
          end
        end
      end
      resources :accounts do
        resources :templates_folders, only: [:index, :show]
        resources :templates, only: [:index, :show] do
          member do
            get :attachments
          end
        end
        resources :triggers, only: [:index, :show] do
          member do
            get :templates_triggerses
            get :filters
            get :conditions
          end
        end
        resources :scheduled_mails, only: [:index, :show]
      end
    end
  end

  namespace :mailchimp do

    resource :subscription

    resource :configuration do
      get :integration, to: 'configurations#integration'
      member do
        get :primary_list
        get :sync_now
      end
    end

    resources :lists, only: [:update] do
      member do
        get :segments
        get :status
        get :members
        get :remove_member
        post :receive_notifications
        post :update_notifications
        post :update_single_notification
        post :remove_notifications
      end
      collection do
        post :preview_scope
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
  resources :templates_folders do
    resources :templates
  end
  resources :templates do
    resources :attachments
    member do
      get "edit_html"
      post 'deliver'
      put :mercury_update
    end
    collection do
      get "new_html"
      put :mercury_create
    end
  end
  resources :activities, only: [:destroy, :index]

  post 'sns', to: 'message_door#sns'
  get 'message_door', to: 'message_door#catch'
  get "ping", to: "message_door#ping"
  root to: 'templates#index'
end
