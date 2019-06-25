defmodule FuragentWeb.FreeAgentController do
  use FuragentWeb, :controller
  alias Furagent.FreeAgent.FreeAgent

  def sync_contacts(conn, _params) do
    FreeAgent.sync_resources("contacts")
    redirect(conn, to: Routes.invoice_path(conn, :new))
  end

  def sync_price_list_items(conn, _params) do
    FreeAgent.sync_resources("price_list_items")
    redirect(conn, to: Routes.invoice_path(conn, :new))
  end

end
