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
    changeset = Invoice.changeset(%Invoice{}, %{})
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

  def edit(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id)
    changeset = Invoice.changeset(invoice, %{})
    render(conn, "edit.html", invoice: invoice, changeset: changeset)
  end


  def show(conn, %{"id" => id}) do
    invoice = Repo.get!(Invoice, id)
    render(conn, "show.html", invoice: invoice)
  end

  def update(conn, %{"id" => id, "invoice" => invoice_params}) do
    invoice = Repo.get!(Invoice, id)

    invoice
    |> Invoice.changeset(invoice_params)
    |> Repo.update()
    |> case do
      {:ok, invoice} ->
        conn
        |> put_flash(:info, "Invoice updated successfully.")
        |> redirect(to: Routes.invoice_path(conn, :show, invoice))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invoice: invoice, changeset: changeset)
    end
  end

end
