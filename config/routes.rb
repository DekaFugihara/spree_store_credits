Spree::Core::Engine.routes.append do
  namespace :admin do
    resources :store_credits do
      get 'users', on: :collection
    end
    resources :users do
      resources :store_credits
    end
  end
end
