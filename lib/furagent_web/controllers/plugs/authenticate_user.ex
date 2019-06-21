defmodule Furagent.Plugs.AuthenticateUser do
  import Plug.Conn
  import Phoenix.Controller

  alias FuragentWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns.user_signed_in? do
      conn
    else
      conn
      |> redirect(to: Helpers.session_path(conn, :new))
      |> halt()
    end
  end
end
