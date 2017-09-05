Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  root 'home#index'
  get '/help' => 'help#faq'
  get '/dashboard' => 'dashboard#index'
  get '/dashboard/stunnel/view' => 'stunnel#view'
  get '/dashboard/stunnel/new' => 'stunnel#new'
end
