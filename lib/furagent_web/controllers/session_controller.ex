defmodule FuragentWeb.SessionController do

  use FuragentWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

end
