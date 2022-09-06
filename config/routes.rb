Rails.application.routes.draw do
  resources :articles do
    match '/scrape', to: 'articles#scrape', via: :post, on: :collection
  end

  root to: 'articles#index'
end