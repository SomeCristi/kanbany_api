Rails.application.routes.draw do
  resources :boards do
    resources :memberships, only: [:create]
    resources :columns do
      resources :tasks
    end
  end

  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
  put '/users/:id/change_role', to: 'users#change_role'
end
