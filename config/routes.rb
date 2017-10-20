Rails.application.routes.draw do
  resources :projects
 
  get '/objectives/new'         => 'objectives#new',      :new_objective
  get '/objectives/destroy/:id' => 'objectives#destroy',  :destroy_objective
  get '/results/new'            => 'results#new',         :new_result
  get '/results/destroy/:id'    => 'results#destroy',     :destroy_result
  get '/indicators/new'         => 'indicator#new',       :new_indicator
  get '/indicators/destroy/:id' => 'indicators#destroy',  :destroy_indicator

  root "projects#index"
end
