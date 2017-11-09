Rails.application.routes.draw do
  resources :projects
  resources :objectives, only: [:new, :destroy]
  resources :results, only: [:new, :destroy]
  resources :indicators, only: [:new, :destroy]

  root "projects#index"
end
