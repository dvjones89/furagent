defmodule Furagent.FreeAgent.FreeAgent do
  alias Furagent.Repo
  alias Furagent.Contact.Contact
  alias Furagent.PriceListItem.PriceListItem

  @supported_resources %{
    "contacts" => %{
      :database_model => Contact,
      :attribute_mappings => %{
        :first_name => "first_name",
        :last_name => "last_name",
        :organisation_name => "organisation_name"
        }
      },
    "price_list_items" => %{
      :database_model => PriceListItem,
      :attribute_mappings => %{
        :name => "code",
        :price => "price",
        :type => "item_type"
      }
    }
  }


  def sync_resources(resource_name) do
    if Enum.member?(Map.keys(@supported_resources), resource_name) do
      database_model = @supported_resources[resource_name][:database_model]
      local_resources = Repo.all(database_model)
      remote_resources = get_resources_from_freeagent(resource_name)

      Enum.each remote_resources, fn(freeagent_resource) ->
        freeagent_id = id_from_url(freeagent_resource["url"])

        local_resource = case Repo.get_by(database_model, freeagent_id: freeagent_id) do
          nil -> struct(database_model, freeagent_id: freeagent_id)
          resource -> resource
        end

        attribute_mappings = @supported_resources[resource_name][:attribute_mappings]
        attrs = Enum.reduce(attribute_mappings, %{}, fn tuple, attrs ->
          Map.put(attrs, elem(tuple, 0), freeagent_resource[elem(tuple, 1)])
        end)

        changeset = apply(database_model, :changeset, [local_resource, attrs])
        Repo.insert_or_update(changeset)
      end

      ids_in_furagent = Enum.map(local_resources, fn resource -> resource.freeagent_id end)
      ids_in_freeagent = Enum.map(remote_resources, fn resource -> id_from_url(resource["url"]) end)
      ids_to_delete = MapSet.difference(MapSet.new(ids_in_furagent), MapSet.new(ids_in_freeagent)) |> MapSet.to_list

      Enum.each ids_to_delete, fn(freeagent_id) ->
        Repo.get_by(database_model, freeagent_id: freeagent_id) |> Repo.delete
      end
    else
      raise "Unsupported resource #{resource_name}."
    end
  end

  def create_invoice(params) do
    contact_id = Map.fetch!(params, "contact_id")
    contact = Repo.get(Contact, contact_id)
    invoice_items = create_invoice_items(params)
    create_invoice_in_freeagent(contact, invoice_items)
  end

  defp create_invoice_items(params) do
    fa_price_list_item_id = Map.fetch!(params, "price_list_item_id")
    price_list_item = Repo.get(PriceListItem, fa_price_list_item_id)

    quantity = Map.fetch!(params, "quantity")

    start_date = Map.fetch!(params, "start_date") |> Date.from_iso8601!
    end_date = Map.fetch!(params, "end_date") |> Date.from_iso8601!
    description = Map.fetch!(params, "description")

    Date.range(end_date, start_date) |> Enum.reduce([], fn date, item_list ->
      new_item = %{
        quantity: quantity,
        item_type: price_list_item.type,
        price: "#{price_list_item.price}",
        description: "#{date}: #{price_list_item.name}: #{description}"
      }
      [new_item | item_list]
    end)
  end

  defp create_invoice_in_freeagent(contact, invoice_items) do
    access_token = System.get_env("FREEAGENT_ACCESS_TOKEN") || refresh_access_token()
    headers = ["Authorization": "Bearer #{access_token}", "Content-Type": "application/json"]
    request = Poison.encode!(%{"invoice" => %{contact: Contact.to_url(contact), dated_on: Date.utc_today, payment_terms_in_days: 14, invoice_items: invoice_items}})

    case HTTPoison.post(Path.join(freeagent_url(), "invoices"), request, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        IO.puts("Invoice created successfully! #{Poison.decode!(body)["invoice"]["url"]}")
        true
      {:ok, %HTTPoison.Response{status_code: 401, body: body}} ->
        IO.puts("\n Received a 401 response from FreeAgent. Refreshing access token and retrying...")
        IO.inspect(Poison.decode(body))
        refresh_access_token()
        create_invoice_in_freeagent(contact, invoice_items)
      {:ok, %HTTPoison.Response{body: body}}
        IO.puts("\n Received an unhandled response from FreeAgent's API. Raw response below...")
        IO.inspect(Poison.decode(body))
        false
    end
  end

  defp get_resources_from_freeagent(resource, page_number \\ 1, retrieved_resources \\ []) do
    access_token = System.get_env("FREEAGENT_ACCESS_TOKEN") || refresh_access_token()
    headers = ["Authorization": "Bearer #{access_token}"]
    params = [page: page_number, per_page: 100 ]

    case HTTPoison.get(Path.join(freeagent_url(), resource), headers, params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, headers: headers, body: body}} ->
        retrieved_resources = Enum.concat(retrieved_resources, Poison.decode!(body)[resource])
        fa_contact_count = Enum.into(headers, %{})["X-Total-Count"] |> String.to_integer

        if length(retrieved_resources) < fa_contact_count do
          get_resources_from_freeagent(resource, page_number + 1, retrieved_resources)
        else
          retrieved_resources
        end

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        refresh_access_token()
        get_resources_from_freeagent(resource)

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "Encountered error querying FreeAgent: #{reason}"
    end
  end

  defp refresh_access_token do
    options = [hackney: [basic_auth: {System.get_env("FREEAGENT_CLIENT_ID"), System.get_env("FREEAGENT_CLIENT_SECRET")}]]
    headers = %{"Content-Type" => "application/x-www-form-urlencoded"}
    body = URI.encode_query(%{"grant_type" => "refresh_token", "refresh_token" => System.get_env("FREEAGENT_REFRESH_TOKEN")})
    response = HTTPoison.post!(Path.join(freeagent_url(), "token_endpoint"), body, headers, options)
    new_access_token = Poison.decode!(response.body)["access_token"]
    System.put_env("FREEAGENT_ACCESS_TOKEN", new_access_token)
    new_access_token
  end

  defp freeagent_url do
    if Mix.env == :prod do
      "https://api.freeagent.com/v2"
    else
      "https://api.sandbox.freeagent.com/v2"
    end
  end

  defp id_from_url(url) do
    String.split(url, "/") |> List.last |> String.to_integer
  end

end
