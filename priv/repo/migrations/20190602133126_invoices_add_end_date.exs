defmodule Furagent.Repo.Migrations.InvoicesAddEndDate do
  use Ecto.Migration

  def change do
    alter table("invoices") do
      add :end_date, :date
    end
  end
end
