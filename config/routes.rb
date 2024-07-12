Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    # Add other controllers as needed
  }
  
  get 'payments/new'
  get 'payments/create'
  post 'payments/create', to: 'payments#create'
  get 'payment_success', to: 'payments#success', as: 'payment_success' 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
