defmodule FootballMarket.Market.SaleStore do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.Accounts.User
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    Consistency,
    CreditBalance,
    Error,
    Holding,
    InitialRecipient,
    Issuance,
    Quote,
    Sale,
    SaleCreditEntry,
    SaleTokenTransfer
  }

  def execute(input) do
    if Repo.in_transaction?() do
      Error.new(:invalid_request, :transaction_in_progress)
    else
      safely(fn -> transaction(input) end)
    end
  end

  defp transaction(input), do: Repo.transaction(fn -> transact(input) end)

  def get_for_seller(seller, id) do
    safely(fn -> lookup(seller, id) end)
  end

  defp lookup(seller, id) do
    case Repo.one(from sale in Sale, where: sale.id == ^id and sale.seller_id == ^seller) do
      nil -> {:error, :not_found}
      sale -> {:ok, evidence(sale)}
    end
  end

  defp transact(input) do
    if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
      do: reject(:invalid_request)

    Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [
      input.seller_id <> ":sale:" <> input.request_key
    ])

    previous =
      Repo.one(
        from sale in Sale,
          where: sale.seller_id == ^input.seller_id and sale.request_key == ^input.request_key
      )

    cond do
      previous == nil ->
        complete(input)

      previous.player_id == input.player_id and previous.quantity == input.quantity ->
        evidence(previous)

      true ->
        reject(:key_conflict)
    end
  end

  defp complete(input) do
    {issuance, balances, holdings, quote} = lock_market!(input)

    {recipient_balance, seller_balance, seller_holding, recipient_holding, total} =
      eligible!(input, issuance, balances, holdings, quote)

    now = DateTime.utc_now()
    adjust_balance!(recipient_balance, Decimal.negate(total), now)
    credit_seller!(seller_balance, input.seller_id, total, now)

    Repo.update!(
      Ecto.Changeset.change(seller_holding, quantity: seller_holding.quantity - input.quantity)
    )

    Repo.update!(
      Ecto.Changeset.change(recipient_holding,
        quantity: recipient_holding.quantity + input.quantity
      )
    )

    sale = insert_sale!(input, issuance, quote, total, now)

    Repo.insert!(%SaleTokenTransfer{
      sale_id: sale.id,
      player_id: input.player_id,
      from_user_id: input.seller_id,
      to_user_id: issuance.recipient_id,
      quantity: input.quantity,
      inserted_at: now
    })

    for {side, user} <- [{"debit", issuance.recipient_id}, {"credit", input.seller_id}] do
      Repo.insert!(%SaleCreditEntry{
        sale_id: sale.id,
        user_id: user,
        side: side,
        amount: total,
        inserted_at: now
      })
    end

    evidence(sale)
  end

  defp lock_market!(input) do
    if is_nil(
         Repo.one(from player in Player, where: player.id == ^input.player_id, lock: "FOR UPDATE")
       ),
       do: reject(:player_not_found)

    issuance = Repo.one(from item in Issuance, where: item.player_id == ^input.player_id)
    if is_nil(issuance), do: reject(:not_initialized)
    if issuance.recipient_id == input.seller_id, do: reject(:self_sale)

    user_ids = Enum.sort([input.seller_id, issuance.recipient_id])

    users =
      Repo.all(
        from user in User, where: user.id in ^user_ids, order_by: user.id, lock: "FOR UPDATE"
      )

    if length(users) != 2, do: reject(:inconsistent_state)

    balances =
      Repo.all(
        from balance in CreditBalance,
          where: balance.user_id in ^user_ids,
          order_by: balance.user_id,
          lock: "FOR UPDATE"
      )

    holdings = Repo.all(from holding in Holding, where: holding.player_id == ^input.player_id)

    quote =
      case Quotes.latest(input.player_id) do
        {:ok, current} -> current
        {:error, :temporarily_unavailable} -> reject(:temporarily_unavailable)
        _ -> reject(:quote_unavailable)
      end

    unless exact_positive?(quote.unit_price), do: reject(:quote_unavailable)
    coherent!(input.player_id, issuance, holdings)
    {issuance, balances, holdings, quote}
  end

  defp eligible!(input, issuance, balances, holdings, quote) do
    total = exact_total!(quote.unit_price, input.quantity)
    recipient_balance = Enum.find(balances, &(&1.user_id == issuance.recipient_id))
    seller_balance = Enum.find(balances, &(&1.user_id == input.seller_id))
    seller_holding = Enum.find(holdings, &(&1.user_id == input.seller_id))
    recipient_holding = Enum.find(holdings, &(&1.user_id == issuance.recipient_id))

    if seller_holding == nil or seller_holding.quantity < input.quantity,
      do: reject(:insufficient_tokens)

    if recipient_holding == nil, do: reject(:inconsistent_state)

    if recipient_balance == nil or Decimal.compare(recipient_balance.amount, total) == :lt,
      do: reject(:insufficient_market_funds)

    {recipient_balance, seller_balance, seller_holding, recipient_holding, total}
  end

  defp coherent!(player, issuance, holdings) do
    fixed = Repo.get(InitialRecipient, 1)

    state = %{
      player_id: player,
      recipient_id: issuance.recipient_id,
      fixed_recipient: fixed && fixed.user_id,
      issuance_recipients: Repo.all(from item in Issuance, select: item.recipient_id),
      issuance: issuance,
      holdings: holdings,
      quotes: Repo.all(from quote in Quote, where: quote.player_id == ^player),
      user_ids: Repo.all(from user in User, select: user.id)
    }

    unless Consistency.validate(state) == {:ok, :issued}, do: reject(:inconsistent_state)
  end

  defp exact_positive?(%Decimal{coef: coefficient, sign: 1} = number)
       when is_integer(coefficient) and coefficient > 0,
       do: Decimal.equal?(number, Decimal.round(number, 2))

  defp exact_positive?(_), do: false

  defp exact_total!(unit_price, quantity) do
    case Repo.query!("SELECT $1::numeric * $2::numeric", [unit_price, quantity]).rows do
      [[%Decimal{} = total]] -> total
      _ -> reject(:inconsistent_state)
    end
  end

  defp credit_seller!(nil, seller_id, total, now),
    do: Repo.insert!(%CreditBalance{user_id: seller_id, amount: total, updated_at: now})

  defp credit_seller!(balance, _seller_id, total, now),
    do: adjust_balance!(balance, total, now)

  defp adjust_balance!(balance, delta, now) do
    case Repo.query!(
           "UPDATE market_credit_balances SET amount = amount + $1::numeric, updated_at = $2 WHERE user_id = $3",
           [delta, now, Ecto.UUID.dump!(balance.user_id)]
         ).num_rows do
      1 -> :ok
      0 -> reject(:inconsistent_state)
    end
  end

  defp insert_sale!(input, issuance, quote, total, now) do
    Repo.insert!(%Sale{
      seller_id: input.seller_id,
      recipient_id: issuance.recipient_id,
      player_id: input.player_id,
      request_key: input.request_key,
      quantity: input.quantity,
      quote_id: quote.id,
      unit_price: quote.unit_price,
      total: total,
      quote_effective_at: quote.effective_at,
      rule_id: quote.rule_id,
      rule_version: quote.rule_version,
      configuration_version_id: quote.configuration_version_id,
      mapping_id: quote.mapping_id,
      performance_sequence: quote.performance_sequence,
      completed_at: now
    })
  end

  defp evidence(sale) do
    sale
    |> Map.from_struct()
    |> Map.drop([:__meta__])
    |> Map.put(
      :transfer,
      Repo.one(from transfer in SaleTokenTransfer, where: transfer.sale_id == ^sale.id)
    )
    |> Map.put(
      :ledger,
      Repo.all(
        from entry in SaleCreditEntry,
          where: entry.sale_id == ^sale.id,
          order_by: entry.side
      )
    )
  end

  defp reject(kind), do: Repo.rollback(%Error{kind: kind, reason: kind})

  defp safely(fun) do
    fun.()
  rescue
    _ in [
      Postgrex.Error,
      DBConnection.ConnectionError,
      Ecto.ConstraintError,
      Ecto.InvalidChangesetError
    ] ->
      Error.new(:temporarily_unavailable, :storage_rejected)
  end
end
