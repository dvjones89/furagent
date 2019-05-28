defmodule Furagent.FreeAgent.FreeAgent do

  def get_contacts do
    access_token = System.get_env("FREEAGENT_ACCESS_TOKEN") || refresh_access_token
    headers = ["Authorization": "Bearer #{access_token}"]

    case HTTPoison.get("https://api.sandbox.freeagent.com/v2/contacts", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts "Received 200 Response From FreeAgent. Decoding JSON"
        Poison.decode!(body)["contacts"]
      {:ok, %HTTPoison.Response{status_code: 401}} ->
        IO.puts "Received 401 Response From FreeAgent. Refreshing access token."
        refresh_access_token()
        get_contacts()
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect "Received Error From FreeAgent API: #{reason}"
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
