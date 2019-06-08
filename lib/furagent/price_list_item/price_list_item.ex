defmodule Furagent.PriceListItem.PriceListItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "price_list_items" do
    field :freeagent_price_list_id, :integer
    field :name, :string
    field :type, :string
    field :price, :decimal

    timestamps()
  end

  @doc false
  def changeset(price_list_item, attrs) do
    price_list_item
    |> cast(attrs, [:name, :type, :price, :freeagent_price_list_id])
    |> validate_required([:name, :type, :price, :freeagent_price_list_id])
  end
end
