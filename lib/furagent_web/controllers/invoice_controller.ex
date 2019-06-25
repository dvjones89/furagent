defmodule FuragentWeb.InvoiceController do
  use FuragentWeb, :controller

  alias Furagent.Invoice.Invoice
  alias Furagent.Contact.Contact
  alias Furagent.PriceListItem.PriceListItem
  alias Furagent.Repo
  alias Furagent.FreeAgent.FreeAgent

  plug Furagent.Plugs.AuthenticateUser

  def index(conn, _params) do
    invoices = Invoice.list_invoices()
    render(conn, "index.html", invoices: invoices)
  end

  def new(conn, _params) do
    contact_list = Repo.all(Contact)
    price_list_items = Repo.all(PriceListItem)
    contacts = Enum.map(contact_list, fn c -> {Contact.display_name(c), c.id} end)
    price_list_items = Enum.map(price_list_items, fn item -> {item.name, item.id} end)
    quantity_options = [1,2,3,4]
    changeset = Invoice.changeset(%Invoice{}, %{start_date: Date.utc_today, end_date: Date.add(Date.utc_today, 6)})
    render(conn, "new.html", changeset: changeset, contacts: contacts, price_list_items: price_list_items, quantity_options: quantity_options)
  end

  def create(conn, %{"invoice" => invoice_params }) do
    FreeAgent.create_invoice(invoice_params)
    redirect(conn, to: Routes.invoice_path(conn, :new))
  end

end
