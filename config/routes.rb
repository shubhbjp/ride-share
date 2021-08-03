Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "dashboard#index"
  get "users/new", to: "users#new"
  get "users/list", to: "users#list"
  post "users/create", to: "users#create"

  get "vehicle/new", to: "vehicle#new"
  get "vehicle/list", to: "vehicle#list"
  post "vehicle/create", to: "vehicle#create"

  get "ride/offer", to: "ride#new"
  post "offer-ride/create", to: "ride#create"
  get "ride/list", to: "ride#list"
  get "ride/select/:id", to: "ride#select"
  get "ride/end", to: "ride#end"
  get "ride/stats", to:"ride#stats"

end
