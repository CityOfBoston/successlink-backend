Rails.application.routes.draw do
  get 'travel_time/get'
  resources :position_imports, only: [:create]

  scope 'api' do
    resources :rehire_sites do
      get 'get_uniq_sites', to: 'rehire_sites#get_uniq_sites', on: :collection
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
