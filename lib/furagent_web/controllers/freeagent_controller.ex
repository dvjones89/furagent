defmodule FuragentWeb.FreeAgentController do
  use FuragentWeb, :controller
  alias Furagent.Invoice.Invoice
  alias Furagent.Contact.Contact
  alias Furagent.Repo

  def sync_contacts(conn, _params) do
    options = [hackney: [basic_auth: {System.get_env("FREEAGENT_CLIENT_ID"), System.get_env("FREEAGENT_CLIENT_SECRET")}]]
    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}
    body = URI.encode_query(%{"grant_type" => "refresh_token", "refresh_token" => System.get_env("FREEAGENT_REFRESH_TOKEN")})
    response = HTTPoison.post!("https://api.sandbox.freeagent.com/v2/token_endpoint", body, headers, options)
    access_token = Poison.decode!(response.body)["access_token"]
    headers = ["Authorization": "Bearer #{access_token}"]
    response = HTTPoison.get!("https://api.sandbox.freeagent.com/v2/contacts", headers)
    contact_list = Poison.decode!(response.body)["contacts"]

    Enum.each contact_list, fn(fa_contact) ->
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
