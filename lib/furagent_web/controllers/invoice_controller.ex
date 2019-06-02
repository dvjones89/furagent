defmodule FuragentWeb.InvoiceController do
  use FuragentWeb, :controller
  alias Furagent.Invoice.Invoice
  alias Furagent.Contact.Contact
  alias Furagent.Repo

  def index(conn, _params) do
    invoices = Invoice.list_invoices()
    render(conn, "index.html", invoices: invoices)
  end

  def new(conn, _params) do
    contact_list = Repo.all(Contact)
    contacts = Enum.map(contact_list, fn c -> c.first_name end)
    changeset = Invoice.changeset(%Invoice{}, %{start_date: Date.utc_today, end_date: Date.add(Date.utc_today, 7)})
    render(conn, "new.html", changeset: changeset, contacts: contacts)
  end

  def create(conn, %{"invoice" => invoice_params}) do
    case Invoice.create_invoice(invoice_params) do
      {:ok, invoice} ->
        conn
        |> put_flash(:info, "Invoice created successfully.")
        |> redirect(to: Routes.invoice_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

end
