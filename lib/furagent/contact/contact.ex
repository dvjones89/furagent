defmodule Furagent.Contact.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :first_name, :string
    field :freeagent_contact_id, :integer
    field :last_name, :string

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:first_name, :last_name, :freeagent_contact_id])
    |> validate_required([:first_name, :last_name, :freeagent_contact_id])
  end
end
