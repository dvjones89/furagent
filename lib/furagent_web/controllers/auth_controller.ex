defmodule FuragentWeb.AuthController do
  alias Furagent.Repo
  alias Furagent.User.User

  use FuragentWeb, :controller
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Oh no, something went wrong! Please try again.")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user = Repo.get_by(User, email: auth.info.email)
    if user do
      conn
      |> put_session(:current_user_id, user.id)
      |> redirect(to: Routes.invoice_path(conn, :new))
    else
      conn
      |> put_flash(:error, "Oh no! #{auth.info.email} isn't authorised to access this service.")
      |> redirect(to: Routes.session_path(conn, :new))
    end

  end
end
