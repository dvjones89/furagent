defmodule Furagent.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :first_name, :string
      add :last_name, :string
      add :freeagent_contact_id, :integer

      timestamps()
    end

  end
end
