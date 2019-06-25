defmodule Furagent.Repo.Migrations.ContactsUpdateFreeagentIdField do
  use Ecto.Migration

  def change do
    rename table("contacts"), :freeagent_contact_id, to: :freeagent_id 
  end
end
