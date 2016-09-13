defmodule Stripe.Coupons do
  @moduledoc """
  Handles coupons to the Stripe API.
  (API ref: https://stripe.com/docs/api#coupons)

  Operations:
  - create
  - retrieve
  - update
  - delete
  - list (TODO)
  """

  @endpoint "coupons"

  def create(params) do
    create params, Stripe.config_or_env_key 
  end

  @doc """
  Creates a new coupon with the given parameters

  ## Examples
  ```
    params = [
      id: "FALL25OFF",
      duration: "once",
      amount_off: 2500,
      currency: "usd"
    ]
  ```

  """
  def create(params, key) do
    Stripe.make_request_with_key(:post, @endpoint, key, params)
    |> Stripe.Util.handle_stripe_response 
  end

  @doc """
  Retrieves the coupon with the given ID.
  Returns a coupon if a valid coupon ID was provided.
  Throws an error otherwise.

  ## Examples
  ```
    params = "free-1-month"

    {:ok, result} = Stripe.Coupons.retrieve params
  ```
  """
  def retrieve(params) do
    path = @endpoint <> "/" <> params

    Stripe.make_request(:get, path, %{}, %{})
    |> Stripe.Util.handle_stripe_response
  end

  def update(coupon_id, params) do
    update coupon_id, params, Stripe.config_or_env_key 
  end

  @doc """
  Updates a coupon with the given parameters
  """
  def update(coupon_id, params, key) do
    Stripe.make_request_with_key(:post, "#{@endpoint}/#{coupon_id}", key, params)
    |> Stripe.Util.handle_stripe_response
  end

  def delete(coupon_id) do
    delete coupon_id, Stripe.config_or_env_key
  end

  @doc """
  Deletes a coupon with the specified ID  
  """
  def delete(coupon_id, key) do
    Stripe.make_request_with_key(:delete, "#{@endpoint}/#{coupon_id}", key)
    |> Stripe.Util.handle_stripe_response
  end

end
