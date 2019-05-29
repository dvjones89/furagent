defmodule Furagent.FreeAgent.FreeAgent do

  def get_contacts(page_number \\ 1, retrieved_contacts \\ []) do
    access_token = System.get_env("FREEAGENT_ACCESS_TOKEN") || refresh_access_token
    headers = ["Authorization": "Bearer #{access_token}"]
    params = [page: page_number, "per_page": 100 ]

    case HTTPoison.get("https://api.sandbox.freeagent.com/v2/contacts", headers, params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: body}} ->
        retrieved_contacts = Enum.concat(retrieved_contacts, Poison.decode!(body)["contacts"])
        fa_contact_count = Enum.into(headers, %{})["X-Total-Count"] |> String.to_integer

        if length(retrieved_contacts) < fa_contact_count do
          get_contacts(page_number + 1, retrieved_contacts)
        else
          retrieved_contacts
        end

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        refresh_access_token()
        get_contacts()

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "Encountered error querying FreeAgent: #{reason}"
    end
  end

  def refresh_access_token do
    options = [hackney: [basic_auth: {System.get_env("FREEAGENT_CLIENT_ID"), System.get_env("FREEAGENT_CLIENT_SECRET")}]]
    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}
    body = URI.encode_query(%{"grant_type" => "refresh_token", "refresh_token" => System.get_env("FREEAGENT_REFRESH_TOKEN")})
    response = HTTPoison.post!("https://api.sandbox.freeagent.com/v2/token_endpoint", body, headers, options)
    new_token = Poison.decode!(response.body)["access_token"]
    System.put_env("FREEAGENT_ACCESS_TOKEN", new_token)
  end

end
