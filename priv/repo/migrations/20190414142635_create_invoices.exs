defmodule Furagent.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :reference, :string, null: false
      add :description, :string

      timestamps()
    end

  end
end
