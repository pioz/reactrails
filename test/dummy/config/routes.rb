Rails.application.routes.draw do
  mount Reactrails::Engine => "/reactrails"

  get "home" => "application#home", as: :home
end
