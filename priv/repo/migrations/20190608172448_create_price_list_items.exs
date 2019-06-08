defmodule Furagent.Repo.Migrations.CreatePriceListItems do
  use Ecto.Migration

  def change do
    create table(:price_list_items) do
      add :name, :string
      add :price, :decimal
      add :freeagent_price_list_id, :integer

      timestamps()
    end

  end
end
