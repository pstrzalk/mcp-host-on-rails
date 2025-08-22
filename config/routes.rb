Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  get  "/mcp_chat/toolbox", to: "mcp_chat#toolbox"
  get  "/mcp_chat/new", to: "mcp_chat#new"
  post "/mcp_chat/chat", to: "mcp_chat#chat"
  post "/mcp_chat/confirm_tool_yes", to: "mcp_chat#confirm_tool_yes"
  post "/mcp_chat/confirm_tool_no", to: "mcp_chat#confirm_tool_no"
  get  "/mcp_chat/", to: "mcp_chat#show"

  resources :mcp_servers, only: [:index, :create, :destroy]

  root "mcp_chat#show"
end
