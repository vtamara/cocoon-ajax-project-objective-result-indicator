Rails.application.routes.draw do
  resources :projects
  get '/objectives/new',        to: 'objectives#new',     as: :new_objective
  get '/results/new',           to: 'results#new',        as: :new_result
  get '/indicators/new',        to: 'indicators#new',      as: :new_indicator
  root "projects#index"
end
