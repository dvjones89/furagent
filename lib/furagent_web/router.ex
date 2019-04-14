defmodule FuragentWeb.Router do
  use FuragentWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FuragentWeb do
    pipe_through :browser
    resources "/invoices", InvoiceController
  end


  # Other scopes may use custom stacks.
  # scope "/api", FuragentWeb do
  #   pipe_through :api
  # end
end
