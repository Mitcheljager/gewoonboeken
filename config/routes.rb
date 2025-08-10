Rails.application.routes.draw do
  concern :paginatable do
    get "(pagina/:page)", action: :index, on: :collection, as: ""
  end

  root "pages#index"

  get "up", to: "rails/health#show", as: :rails_health_check
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # User and session
  resources :sessions, only: [:create, :destroy]

  get "login", to: "sessions#new", as: "login"
  get "logout", to: "sessions#destroy", as: "logout"

  # Books and related
  resources :authors, path: "naam", param: :slug, only: [:show]
  resources :genres, param: :slug, only: [:show]

  get "boek/:slug_and_isbn", to: "books#show", as: :book
  get "boeken", to: "books#index", as: :books, concerns: :paginatable

  get "book/listings/:slug_and_isbn", to: "books#listings_summary_partial", as: :book_listings_summary
  get "book/request_scrape/:slug_and_isbn", to: "books#request_scrape", as: :book_request_scrape

  # Actions
  get "actions/index_by_isbn/:isbn", to: "actions#index_by_isbn"
  post "actions/attach_image_for_isbn", to: "actions#attach_image_for_isbn", as: :attach_image_for_isbn
  post "actions/run_all_scrapers_for_isbn", to: "actions#run_all_scrapers_for_isbn", as: :run_all_scrapers_for_isbn
  post "actions/generate_ai_description_for_isbn", to: "actions#generate_ai_description_for_isbn", as: :generate_ai_description_for_isbn
  post "actions/generate_ai_keywords_for_isbn", to: "actions#generate_ai_keywords_for_isbn", as: :generate_ai_keywords_for_isbn
  post "actions/generate_ai_description_for_author", to: "actions#generate_ai_description_for_author", as: :generate_ai_description_for_author

  # Pages
  get "over-ons", to: "pages#about", as: :about
  get "privacy", to: "pages#privacy", as: :privacy
  get "affiliate", to: "pages#affiliate", as: :affiliate

  namespace :admin do
    get "/", to: "base#index", as: :root

    resources :books, param: :slug_and_isbn
    resources :listings
    resources :sources, param: :slug
    resources :genres, param: :slug
    resources :authors, param: :slug
    resources :users
  end

  direct :rails_public_blob do |blob|
    if ENV["CDN"].present?
      File.join(ENV["CDN"], blob.key)
    else
      url_for(blob)
    end
  end
end
