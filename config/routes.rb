Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :applications, param: :token do
    resources :chats, only: [:index, :show, :create] do
      resources :messages, only: [:index, :show, :create] do
        collection do
          get 'search', to: 'messages#search'
        end
      end
    end
  end
end
