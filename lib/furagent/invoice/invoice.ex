defmodule Furagent.Invoice.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Furagent.Repo
  alias Furagent.Invoice.Invoice

  schema "invoices" do
    field :description, :string
    field :reference, :string

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:reference, :description])
    |> validate_required([:reference])
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
