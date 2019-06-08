defmodule FuragentWeb.FreeAgentController do
  use FuragentWeb, :controller
  alias Furagent.Invoice.Invoice
  alias Furagent.Contact.Contact
  alias Furagent.PriceListItem.PriceListItem
  alias Furagent.Repo
  alias Furagent.FreeAgent.FreeAgent

  def sync_contacts(conn, _params) do
    fa_contacts = FreeAgent.get_resources("contacts")

    Enum.each fa_contacts, fn(fa_contact) ->
      fa_id = fa_contact["url"] |> String.split("/") |> List.last |> String.to_integer
      case Repo.get_by(Contact, freeagent_contact_id: fa_id) do
        nil -> %Contact{freeagent_contact_id: fa_id}
        contact -> contact
      end
      |> Contact.changeset(%{first_name: fa_contact["first_name"], last_name: fa_contact["last_name"], organisation_name: fa_contact["organisation_name"]})
      |> Repo.insert_or_update
    end

    redirect(conn, to: Routes.invoice_path(conn, :new))
  end

  def sync_price_list_items(conn, _params) do
    fa_price_list_items = FreeAgent.get_resources("price_list_items")

    Enum.each fa_price_list_items, fn(fa_price_list_item) ->
      fa_id = fa_price_list_item["url"] |> String.split("/") |> List.last |> String.to_integer
      case Repo.get_by(PriceListItem, freeagent_price_list_id: fa_id) do
        nil -> %PriceListItem{freeagent_price_list_id: fa_id}
        price_list_item -> price_list_item
      end
      |> PriceListItem.changeset(%{name: fa_price_list_item["code"], price: fa_price_list_item["price"], type: fa_price_list_item["type"]})
      |> Repo.insert_or_update
    end

    redirect(conn, to: Routes.invoice_path(conn, :new))
  end
end
