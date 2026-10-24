defmodule FootballMarket.Market.PurchaseInput do
  @moduledoc false
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.Error

  def validate(%AuthenticatedActor{account_id: buyer}, input) when is_map(input) do
    with {:ok, buyer} <- Ecto.UUID.cast(buyer),
         true <-
           Map.keys(input) |> Enum.sort() == Enum.sort([:player_id, :quantity, :request_key]),
         {:ok, player} <- Ecto.UUID.cast(input.player_id),
         true <-
           is_integer(input.quantity) and input.quantity > 0 and input.quantity <= 2_147_483_647,
         true <- valid_key?(input.request_key) do
      {:ok,
       %{
         buyer_id: buyer,
         player_id: player,
         quantity: input.quantity,
         request_key: input.request_key
       }}
    else
      _ -> Error.new(:invalid_request, :invalid_request)
    end
  end

  def validate(%AuthenticatedActor{}, _), do: Error.new(:invalid_request, :invalid_request)
  def validate(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp valid_key?(key) when is_binary(key),
    do:
      String.valid?(key) and :binary.match(key, <<0>>) == :nomatch and String.trim(key) != "" and
        length(String.codepoints(key)) <= 128

  defp valid_key?(_), do: false
end
