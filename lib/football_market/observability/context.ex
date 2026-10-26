defmodule FootballMarket.Observability.Context do
  @moduledoc "Small, explicitly propagated logging context; never business identity."
  @keys ~w(correlation_id request_id job_id worker queue attempt max_attempts run_id delivery_id intent_id calculation_request_id)a

  def keys, do: @keys
  def capture, do: Keyword.take(Logger.metadata(), @keys)

  def current do
    metadata = Logger.metadata()
    id(metadata[:correlation_id], metadata[:request_id])
  end

  def id(value, fallback \\ nil) do
    cond do
      valid?(value) -> value
      valid?(fallback) -> fallback
      true -> Ecto.UUID.generate()
    end
  end

  def valid?(value) when is_binary(value) and byte_size(value) in 1..200,
    do: String.valid?(value) and :binary.match(value, <<0>>) == :nomatch

  def valid?(_), do: false

  def put(metadata) do
    Logger.reset_metadata(Keyword.merge(Keyword.drop(Logger.metadata(), @keys), metadata))
  end

  def with_context(metadata, fun) do
    previous = Logger.metadata()

    try do
      put(metadata)
      fun.()
    after
      Logger.reset_metadata(previous)
    end
  end
end
