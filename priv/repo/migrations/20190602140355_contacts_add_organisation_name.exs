defmodule Furagent.Repo.Migrations.ContactsAddOrganisationName do
  use Ecto.Migration

  def change do
    alter table("contacts") do
      add :organisation_name, :string
    end
  end
end
