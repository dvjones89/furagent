defmodule FuragentWeb.InvoiceController do
  use FuragentWeb, :controller
  alias Furagent.Invoice.Invoice

  def index(conn, _params) do
    invoices = Invoice.list_invoices()
    render(conn, "index.html", invoices: invoices)
  end

  def new(conn, _params) do
    changeset = Invoice.changeset(%Invoice{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

end
