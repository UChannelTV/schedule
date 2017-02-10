Rails.application.routes.draw do
  [:channels, :providers, :categories, :programs, :program_episodes, :short_clip_priorities,
      :short_clip_promotions].each do |resource|
    resources resource do
      post 'import', :on => :collection, :defaults => { :format => 'json'}
      get 'dump', :on => :collection, :defaults => { :format => 'json'}
    end
  end

  resources :channel_schedule_versions
    
  [:programs, :schedule_programs, :short_clips, :program_episodes, :schedule_program_episodes, 
      :final_schedules].each do |resource|
    resources resource do
      post 'import', :on => :collection, :defaults => { :format => 'json'}
      get 'dump', :on => :collection, :defaults => { :format => 'json'}
      put :index, :on => :collection
      put 'new', :on => :collection
      put 'edit', :on => :member
    end
  end
    
  [:videos].each do |resource|
    resources resource do
      post 'import', :on => :collection, :defaults => { :format => 'json'}
      get 'dump', :on => :collection, :defaults => { :format => 'json'}
      post 'dump', :on => :collection, :defaults => { :format => 'json'}
      put :index, :on => :collection
      get 'sync', :on => :collection
    end
  end
 
  root :to => "program#index"
 
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
