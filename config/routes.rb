Birch::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.
  match 'requests/list' => 'requests#list'
  match 'requests/brafta_update/(:id)' => 'requests#brafta_update'
  resources :requests
  resources :users
  match 'users/delete/:id' => 'users#delete'
  post 'users/:id' => 'users#destroy'
  match '/forgot_password' => 'access#forgot_password'
  match '/send_password_reset' => 'access#send_password_reset'
  match '/reset_password/(:token)' => 'access#reset_password', :as => 'reset'
  match '/requested' => 'requests#requested'
  match 'access/save_password' => 'access#save_password'
  post 'requests/:id' => 'requests#destroy'
  match 'requests/new/(:incident_id)' => 'requests#new'
  match 'requests/delete/:id' => 'requests#delete'
  match 'access/login' => 'access#login'
  match 'access/logout' => 'access#logout'
  match 'access/attempt_login' => 'access#attempt_login'
  root :to => 'requests#index'
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
