defmodule FuragentWeb.FreeAgentController do
  use FuragentWeb, :controller
  alias Furagent.Invoice.Invoice
  alias Furagent.Contact.Contact
  alias Furagent.Repo
  alias Furagent.FreeAgent.FreeAgent

  def sync_contacts(conn, _params) do
    fa_contacts = FreeAgent.get_contacts()

    Enum.each fa_contacts, fn(fa_contact) ->
      fa_id = fa_contact["url"] |> String.split("/") |> List.last |> String.to_integer
      case Repo.get_by(Contact, freeagent_contact_id: fa_id) do
        nil -> %Contact{freeagent_contact_id: fa_id}
        contact -> contact
      end
      |> Contact.changeset(%{first_name: fa_contact["first_name"], last_name: fa_contact["last_name"]})
      |> Repo.insert_or_update
    end

    redirect(conn, to: Routes.invoice_path(conn, :new))
  end
end
