defmodule FuragentWeb.Router do
  use FuragentWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Furagent.Plugs.SetCurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", FuragentWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/", FuragentWeb do
    pipe_through :browser

    get "/", InvoiceController, :new
    resources "/invoices", InvoiceController
    resources "/sessions", SessionController, only: [:new]
    delete "/sign_out", SessionController, :delete
    get "/freeagent/sync_contacts", FreeAgentController, :sync_contacts
    get "/freeagent/sync_price_list_items", FreeAgentController, :sync_price_list_items
  end


  # Other scopes may use custom stacks.
  # scope "/api", FuragentWeb do
  #   pipe_through :api
  # end
end
