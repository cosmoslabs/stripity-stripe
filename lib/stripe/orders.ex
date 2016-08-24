defmodule Stripe.Orders do
  @moduledoc """
  Main API for working with Customers at Stripe. Through this API you can:
  -create orders
  -delete single order
  -delete all order
  -count orders

  Supports Connect workflow by allowing to pass in any API key explicitely (vs using the one from env/config).


  (API ref: https://stripe.com/docs/api/curl#order_object
  """

  @endpoint "orders"

  @doc """
  Creates a Customer with the given parameters - all of which are optional.

  ## Example

  ```
    new_order = [
      currency: "usd",
      email: "test@test.com",
      description: "An Test Account",
      metadata:[
        app_order_id: "ABC123"
        app_state_x: "xyz"
      ],
      items: [
        [
          type: "sku",
          parent: "sku_8rFqplprEgXbUJ"
        ]
      ]
    ]
    {:ok, res} = Stripe.Orders.create new_order
  ```

  """
  def create(params) do
    create params, Stripe.config_or_env_key
  end

  @doc """
  Creates a new Order with the given parameters - all of which are optional.
  Using a given stripe key to apply against the account associated.

  ## Example
  ```
  {:ok, res} = Stripe.Orders.create new_order, key
  ```
  """
  def create(params, key) do
    Stripe.make_request_with_key(:post, @endpoint, key, params)
    |> Stripe.Util.handle_stripe_response
  end

  def pay(id, params) do
    pay id, params, Stripe.config_or_env_key
  end

  def pay(id, params, key) do
    Stripe.make_request_with_key(:post, "#{@endpoint}/#{id}/pay", key, params)
    |> Stripe.Util.handle_stripe_response
  end
  @doc """
  Retrieves a given Order with the specified ID. Returns 404 if not found.
  ## Example

  ```
    {:ok, cust} = Stripe.Orders.get "order_id"
  ```

  """
  def get(id) do
    get id, Stripe.config_or_env_key
  end

  @doc """
  Retrieves a given Customer with the specified ID. Returns 404 if not found.
  Using a given stripe key to apply against the account associated.
  ## Example

  ```
  {:ok, cust} = Stripe.Orders.get "order_id", key
  ```
  """
  def get(id, key) do
    Stripe.make_request_with_key(:get, "#{@endpoint}/#{id}", key)
    |> Stripe.Util.handle_stripe_response
  end


  @doc """
  Updates a Order with the given parameters - all of which are optional.

  ## Example

  ```
    new_fields = [
      email: "new_email@test.com",
    ]
    {:ok, res} = Stripe.Orders.update(order_id, new_fields)
  ```

  """
  def update(order_id, params) do
    update(order_id, params, Stripe.config_or_env_key)
  end

  @doc """
  Updates a Order with the given parameters - all of which are optional.
  Using a given stripe key to apply against the account associated.

  ## Example
  ```
  {:ok, res} = Stripe.Orders.update(order_id, new_fields, key)
  ```
  """
  def update(order_id, params, key) do
    Stripe.make_request_with_key(:post, "#{@endpoint}/#{order_id}", key, params)
    |> Stripe.Util.handle_stripe_response
  end



  @doc """
  Returns a list of Orders with a default limit of 10 which you can override with `list/1`

  ## Example

  ```
    {:ok, customers} = Stripe.Orders.list(starting_after, 20)
  ```
  """
  def list(starting_after,limit \\ 10) do
    list Stripe.config_or_env_key, "", limit
  end

  @doc """
  Returns a list of Orders with a default limit of 10 which you can override with `list/1`
  Using a given stripe key to apply against the account associated.

  ## Example

  ```
  {:ok, orders} = Stripe.Orders.list(key,starting_after,20)
  ```
  """
  def list(key, starting_after, limit) do
    Stripe.Util.list @endpoint, key, starting_after, limit
  end

  @doc """
  Deletes an Order with the specified ID

  ## Example

  ```
  {:ok, resp} =  Stripe.Orders.delete "customer_id"
  ```
  """
  def delete(id) do
    delete id, Stripe.config_or_env_key
  end

  @doc """
  Deletes a Order with the specified ID
  Using a given stripe key to apply against the account associated.

  ## Example

  ```
  {:ok, resp} = Stripe.Orders.delete "customer_id", key
  ```
  """
  def delete(id,key) do
    Stripe.make_request_with_key(:delete, "#{@endpoint}/#{id}", key)
    |> Stripe.Util.handle_stripe_response
  end

  @doc """
  Deletes all Orders

  ## Example

  ```
  Stripe.Orders.delete_all
  ```
  """
  def delete_all do
    case all() do
      {:ok, orders} ->
        Enum.each orders, fn c -> delete(c["id"]) end
      {:error, err} -> raise err
    end
  end

  @doc """
  Deletes all Orders
  Using a given stripe key to apply against the account associated.

  ## Example

  ```
  Stripe.Orders.delete_all key
  ```
  """
  def delete_all key do
    case all() do
      {:ok, orders} ->
        Enum.each orders, fn c -> delete(c["id"], key) end
      {:error, err} -> raise err
    end
  end

  @max_fetch_size 100
  @doc """
  List all orders.

  ##Example

  ```
  {:ok, orders} = Stripe.Orders.all
  ```

  """
  def all( accum \\ [], starting_after \\ "") do
    all Stripe.config_or_env_key, accum, starting_after
  end

  @doc """
  List all orders.
  Using a given stripe key to apply against the account associated.

  ##Example

  ```
  {:ok, orders} = Stripe.Orders.all key, accum, starting_after
  ```
  """
  def all( key, accum, starting_after) do
    case Stripe.Util.list_raw("#{@endpoint}",key, @max_fetch_size, starting_after) do
      {:ok, resp}  ->
        case resp[:has_more] do
          true ->
            last_sub = List.last( resp[:data] )
            all( key, resp[:data] ++ accum, last_sub["id"] )
          false ->
            result = resp[:data] ++ accum
            {:ok, result}
        end
      {:error, err} -> raise err
    end
  end

  @doc """
  Count total number of orders.

  ## Example
  ```
  {:ok, count} = Stripe.Orders.count
  ```
  """
  def count do
    count Stripe.config_or_env_key
  end

  @doc """
  Count total number of orders.
  Using a given stripe key to apply against the account associated.

  ## Example
  ```
  {:ok, count} = Stripe.Orders.count key
  ```
  """
  def count( key )do
    Stripe.Util.count "#{@endpoint}", key
  end
end
