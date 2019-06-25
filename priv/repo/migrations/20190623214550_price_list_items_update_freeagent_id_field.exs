defmodule Furagent.Repo.Migrations.PriceListItemsUpdateFreeagentIdField do
  use Ecto.Migration

  def change do
    rename table("price_list_items"), :freeagent_price_list_id, to: :freeagent_id 
  end
end
