Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'homepages#index'
  resources :games do
    member do
      patch 'forfeit'
    end
    resources :pieces, only: [:create, :show, :update] do
      member do
        patch 'castle'
      end
    end
  end
  get 'games/:id/reload_board', to: 'games#reload_board'

  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
end