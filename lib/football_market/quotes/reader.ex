defmodule FootballMarket.Quotes.Reader do
  @moduledoc "Local immutable quote reads in authoritative player sequence order."
  import Ecto.Query
  alias FootballMarket.{Repo, Catalog.Player, Market.Quote}

  def list_history(player_id) do
    with {:ok, id} <- player_identity(player_id) do
      {:ok,
       Repo.all(
         from q in Quote,
           where: q.player_id == ^id,
           order_by: [
             asc: fragment("COALESCE(?, 0)", q.performance_sequence),
             asc: q.inserted_at,
             asc: q.id
           ]
       )}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def latest(player_id), do: select_quote(player_id, nil)

  def at_date(player_id, %Date{calendar: Calendar.ISO} = date) do
    case DateTime.new(date, ~T[23:59:59.999999], "Etc/UTC") do
      {:ok, cutoff} -> select_quote(player_id, cutoff)
      _ -> {:error, :invalid_date}
    end
  end

  def at_date(_, _), do: {:error, :invalid_date}

  defp select_quote(player_id, cutoff) do
    with {:ok, id} <- player_identity(player_id) do
      query =
        from q in Quote,
          where: q.player_id == ^id,
          order_by: [
            desc: fragment("COALESCE(?, 0)", q.performance_sequence),
            desc: q.effective_at,
            desc: q.inserted_at,
            desc: q.id
          ],
          limit: 1

      query = if cutoff, do: where(query, [q], q.effective_at <= ^cutoff), else: query

      case Repo.one(query) do
        nil -> {:error, :quote_not_found}
        quote -> {:ok, quote}
      end
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp player_identity(value) do
    with true <-
           is_binary(value) and
             Regex.match?(~r/\A[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\z/, value),
         {:ok, id} <- Ecto.UUID.cast(value),
         true <- Repo.exists?(from p in Player, where: p.id == ^id) do
      {:ok, id}
    else
      _ -> {:error, :player_not_found}
    end
  end
end
