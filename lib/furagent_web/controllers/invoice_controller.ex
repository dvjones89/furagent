defmodule FuragentWeb.InvoiceController do
  use FuragentWeb, :controller
  alias Furagent.Invoice.Invoice
  alias Furagent.Contact.Contact
  alias Furagent.Repo
  alias Furagent.FreeAgent.FreeAgent

  def index(conn, _params) do
    invoices = Invoice.list_invoices()
    render(conn, "index.html", invoices: invoices)
  end

  def new(conn, _params) do
    contact_list = Repo.all(Contact)
    contacts = Enum.map(contact_list, fn c -> {Contact.display_name(c), c.id} end)
    changeset = Invoice.changeset(%Invoice{}, %{start_date: Date.utc_today, end_date: Date.add(Date.utc_today, 7)})
    render(conn, "new.html", changeset: changeset, contacts: contacts)
  end

  def create(conn, %{"invoice" => invoice_params }) do
    fa_contact_id = Map.fetch!(invoice_params, "contact_id")
    contact = Repo.get(Contact, fa_contact_id)
    start_date = Map.fetch!(invoice_params, "start_date") |> Date.from_iso8601!
    end_date = Map.fetch!(invoice_params, "end_date") |> Date.from_iso8601!

    invoice_items = Date.range(end_date, start_date) |> Enum.reduce [], fn date, item_list ->
      new_item = %{description: "Dog Walking Chico #{date}", item_type: "Services", quantity: 1, price: 10}
      [new_item | item_list]
    end

    FreeAgent.create_invoice(contact, invoice_items)

    redirect(conn, to: Routes.invoice_path(conn, :new))
  end

end
