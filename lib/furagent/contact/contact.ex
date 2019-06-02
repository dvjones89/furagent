defmodule Furagent.Contact.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :first_name, :string
    field :freeagent_contact_id, :integer
    field :last_name, :string
    field :organisation_name, :string

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:first_name, :last_name, :organisation_name, :freeagent_contact_id])
    |> validate_required([:first_name, :last_name, :freeagent_contact_id])
  end

  def display_name(contact) do
    "#{contact.first_name} #{contact.last_name} #{contact.organisation_name}"
  end
end
