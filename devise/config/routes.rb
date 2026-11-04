LaissCms::Engine.routes.draw do
  namespace :admin,
    path: LaissCms.admin_path,
    constraints: LaissCms.admin_constraints do
    devise_for :user,
      class_name: "LaissCms::User",
      singular: :user,
      skip: :all,
      controllers: {
        sessions: "laiss_cms/admin/user_sessions",
        passwords: "laiss_cms/admin/passwords"
      },
      router_name: :laiss_cms

    devise_scope :user do
      get "/dashboard" => "dashboard#index",
        :as => :user_root
      get "/signup" => "users#signup",
        :as => :signup
      get "/login" => "user_sessions#new",
        :as => :login
      post "/login" => "user_sessions#create"
      match "/logout" => "user_sessions#destroy",
        :as => :logout, :via => Devise.sign_out_via

      get "/passwords" => "passwords#new",
        :as => :new_password
      get "/passwords/:id/edit/:reset_password_token" => "passwords#edit",
        :as => :edit_password
      post "/passwords" => "passwords#create",
        :as => :reset_password
      patch "/passwords" => "passwords#update",
        :as => :update_password
    end

    resources :users
  end
end
