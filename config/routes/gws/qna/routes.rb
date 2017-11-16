SS::Application.routes.draw do
  Gws::Qna::Initializer

  concern :deletion do
    get :delete, on: :member
    delete action: :destroy_all, on: :collection
  end

  gws "qna" do
    resources :topics, concerns: [:deletion] do
      namespace :parent, path: ":parent_id", parent_id: /\d+/ do
        resources :comments, controller: '/gws/qna/comments', concerns: [:deletion]
      end
      get :categories, on: :collection
      post :read, on: :member
      post :resolve, on: :member
      post :unresolve, on: :member
    end

    # with category
    scope(path: ":category", as: "category") do
      resources :topics, concerns: [:deletion] do
        namespace :parent, path: ":parent_id", parent_id: /\d+/ do
          resources :comments, controller: '/gws/qna/comments', concerns: [:deletion]
        end
        get :categories, on: :collection
      end
    end

    resources :categories, concerns: [:deletion]

    namespace "apis" do
      get "categories" => "categories#index"
    end
  end
end