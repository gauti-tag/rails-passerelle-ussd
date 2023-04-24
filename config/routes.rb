Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  match 'mtn/ussd/vignette', to: 'mtn#index', via: [:get, :post]
  match 'orange/ussd/vignette', to: 'orange#index', via: [:get, :post]
end
