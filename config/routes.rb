Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'sibs/transaction' => 'sibs#transaction', :as => :sibs_create_transaction
  get 'sibs/status' => 'sibs#status', :as => :sibs_transaction_status


  # Defines the root path route ("/")
  # root "posts#index"
end
