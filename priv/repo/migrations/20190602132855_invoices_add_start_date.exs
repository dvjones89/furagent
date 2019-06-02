defmodule Furagent.Repo.Migrations.InvoicesAddStartDate do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :start_date, :date
    end
  end
end
