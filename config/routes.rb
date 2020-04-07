Rails.application.routes.draw do
  resources :boards

  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
end
