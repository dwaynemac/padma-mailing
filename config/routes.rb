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
    end
  end

  resources :scheduled_mails
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
