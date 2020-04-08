Rails.application.routes.draw do
  resources :boards do
    resources :columns
    # post :add_user TODO add a way to add users to board
  end

  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
end
