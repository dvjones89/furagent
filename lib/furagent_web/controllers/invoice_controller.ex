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
    fa_contact_id = Map.fetch!(invoice_params, "contact_id")
    fa_price_list_item_id = Map.fetch!(invoice_params, "price_list_item_id")
    quantity = Map.fetch!(invoice_params, "quantity")
    contact = Repo.get(Contact, fa_contact_id)
    price_list_item = Repo.get(PriceListItem, fa_price_list_item_id)
    start_date = Map.fetch!(invoice_params, "start_date") |> Date.from_iso8601!
    end_date = Map.fetch!(invoice_params, "end_date") |> Date.from_iso8601!
    description = Map.fetch!(invoice_params, "description")

    invoice_items = Date.range(end_date, start_date) |> Enum.reduce([], fn date, item_list ->
      new_item = %{
        quantity: quantity,
        item_type: price_list_item.type,
        price: "#{price_list_item.price}",
        description: "#{date}: #{price_list_item.name}: #{description}"
      }
      [new_item | item_list]
    end)

    FreeAgent.create_invoice(contact, invoice_items)

    redirect(conn, to: Routes.invoice_path(conn, :new))
  end

end
