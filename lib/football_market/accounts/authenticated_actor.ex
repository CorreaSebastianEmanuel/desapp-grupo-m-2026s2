defmodule FootballMarket.Accounts.AuthenticatedActor do
  @moduledoc "Trusted identity established by the API authentication boundary."

  @enforce_keys [:account_id, :authentication_method, :credential_id]
  defstruct [:account_id, :authentication_method, :credential_id]
end
