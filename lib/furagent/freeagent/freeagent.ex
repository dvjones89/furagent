defmodule Furagent.FreeAgent.FreeAgent do
  alias Furagent.Contact.Contact

  def get_resources(resource, page_number \\ 1, retrieved_resources \\ []) do
    access_token = System.get_env("FREEAGENT_ACCESS_TOKEN") || refresh_access_token()
    headers = ["Authorization": "Bearer #{access_token}"]
    params = [page: page_number, per_page: 100 ]

    case HTTPoison.get(Path.join(freeagent_url, resource), headers, params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: body}} ->
        retrieved_resources = Enum.concat(retrieved_resources, Poison.decode!(body)[resource])
        fa_contact_count = Enum.into(headers, %{})["X-Total-Count"] |> String.to_integer

        if length(retrieved_resources) < fa_contact_count do
          get_resources(resource, page_number + 1, retrieved_resources)
        else
          retrieved_resources
        end

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        refresh_access_token()
        get_resources("contacts")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "Encountered error querying FreeAgent: #{reason}"
    end
  end

  def create_invoice(contact, invoice_items) do
    access_token = System.get_env("FREEAGENT_ACCESS_TOKEN") || refresh_access_token()
    headers = ["Authorization": "Bearer #{access_token}", "Content-Type": "application/json"]
    request = Poison.encode!(%{"invoice" => %{contact: Contact.to_url(contact), dated_on: Date.utc_today, payment_terms_in_days: 14, invoice_items: invoice_items}})
    HTTPoison.post!("#{freeagent_url()}/invoices", request, headers)
  end

  def refresh_access_token do
    options = [hackney: [basic_auth: {System.get_env("FREEAGENT_CLIENT_ID"), System.get_env("FREEAGENT_CLIENT_SECRET")}]]
    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}
    body = URI.encode_query(%{"grant_type" => "refresh_token", "refresh_token" => System.get_env("FREEAGENT_REFRESH_TOKEN")})
    response = HTTPoison.post!("#{freeagent_url()}/token_endpoint", body, headers, options)
    new_token = Poison.decode!(response.body)["access_token"]
    System.put_env("FREEAGENT_ACCESS_TOKEN", new_token)
  end

  def freeagent_url do
    if Mix.env == :prod do
      "https://api.freeagent.com/v2"
    else
      "https://api.sandbox.freeagent.com/v2"
    end
  end

end
