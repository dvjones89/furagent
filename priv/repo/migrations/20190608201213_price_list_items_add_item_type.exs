defmodule Furagent.Repo.Migrations.PriceListItemsAddItemType do
  use Ecto.Migration

  def change do
    alter table("price_list_items") do
      add :type, :string
    end
  end
end
