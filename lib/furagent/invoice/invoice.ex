defmodule Furagent.Invoice.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Furagent.Repo
  alias Furagent.Invoice.Invoice

  schema "invoices" do
    field :description, :string
    field :reference, :string
    field :start_date, :date
    field :end_date, :date

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:reference, :description, :start_date, :end_date])
    |> validate_required([:description, :start_date, :end_date])
  end

  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  def list_invoices do
    Repo.all(Invoice)
  end
end
