defmodule FuragentWeb.SessionController do

  use FuragentWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def delete(conn, _params) do
    conn
    |> Plug.Conn.configure_session(drop: true)
    |> redirect(to: "/")
  end

end
