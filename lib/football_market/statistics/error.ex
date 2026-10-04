defmodule FootballMarket.Statistics.Error do
  def validation(field, reason),
    do: {:error, %{kind: :validation, field: field, reason: reason, record: nil}}

  def conflict(field),
    do: {:error, %{kind: :conflict, field: field, reason: :duplicate, record: nil}}

  def at({:error, error}, match_index, performance_index) when is_map(error),
    do:
      {:error,
       %{error | record: %{match_index: match_index, performance_index: performance_index}}}

  def changeset(cs) do
    {field, {_message, opts}} = hd(cs.errors)

    case opts[:constraint] do
      :unique -> conflict(field)
      :foreign -> validation(field, :missing_reference)
      _ -> validation(field, :invalid_count)
    end
  end
end
