defmodule FootballMarket.Accounts.Authentication do
  @moduledoc false

  @lifetime_seconds 900
  @required_claims ~w(sub jti iat exp iss aud)

  def lifetime_seconds, do: @lifetime_seconds
  def system_time, do: System.system_time(:second)
  def generate_jti, do: Ecto.UUID.generate()

  def issue(account_id) do
    with {:ok, subject} <- Ecto.UUID.cast(account_id),
         {:ok, config} <- configuration(),
         {:ok, now} <- invoke_integer(config.clock),
         {:ok, jti} <- invoke_uuid(config.jti_provider) do
      claims = %{
        "sub" => subject,
        "jti" => jti,
        "iat" => now,
        "exp" => now + @lifetime_seconds,
        "iss" => config.issuer,
        "aud" => config.audience
      }

      case Joken.generate_and_sign(%{}, claims, config.signer) do
        {:ok, token, _claims} -> {:ok, token}
        _ -> {:error, :issuance_failed}
      end
    else
      _ -> {:error, :issuance_failed}
    end
  rescue
    _ -> {:error, :issuance_failed}
  end

  def validate(token) when is_binary(token) do
    with {:ok, config} <- configuration(),
         {:ok, now} <- invoke_integer(config.clock),
         {:ok, claims} <- Joken.verify(token, config.signer),
         :ok <- validate_claims(claims, config, now) do
      {:ok, %{account_id: claims["sub"], token_id: claims["jti"]}}
    else
      _ -> {:error, :invalid_token}
    end
  rescue
    _ -> {:error, :invalid_token}
  end

  def validate(_token), do: {:error, :invalid_token}

  defp configuration do
    config = Application.get_env(:football_market, __MODULE__, [])

    with issuer when is_binary(issuer) and issuer != "" <- config[:issuer],
         audience when is_binary(audience) and audience != "" <- config[:audience],
         encoded when is_binary(encoded) <- config[:signing_key],
         {:ok, key} when byte_size(key) >= 32 <- Base.decode64(encoded),
         0 <- config[:clock_skew_seconds],
         {clock_module, clock_function, clock_args} = clock <- config[:clock],
         true <- is_atom(clock_module) and is_atom(clock_function) and is_list(clock_args),
         {jti_module, jti_function, jti_args} = jti_provider <- config[:jti_provider],
         true <- is_atom(jti_module) and is_atom(jti_function) and is_list(jti_args) do
      {:ok,
       %{
         issuer: issuer,
         audience: audience,
         signer: Joken.Signer.create("HS256", key),
         clock: clock,
         jti_provider: jti_provider
       }}
    else
      _ -> {:error, :invalid_configuration}
    end
  end

  defp invoke_integer({module, function, args}) do
    case apply(module, function, args) do
      value when is_integer(value) -> {:ok, value}
      _ -> {:error, :invalid_provider}
    end
  end

  defp invoke_uuid(provider) do
    with value when is_binary(value) <- apply_provider(provider),
         {:ok, uuid} <- Ecto.UUID.cast(value) do
      {:ok, uuid}
    else
      _ -> {:error, :invalid_provider}
    end
  end

  defp apply_provider({module, function, args}), do: apply(module, function, args)

  defp validate_claims(claims, config, now) when is_map(claims) do
    with true <- Enum.all?(@required_claims, &Map.has_key?(claims, &1)),
         true <- claims["iss"] == config.issuer,
         true <- claims["aud"] == config.audience,
         {:ok, _subject} <- Ecto.UUID.cast(claims["sub"]),
         {:ok, _jti} <- Ecto.UUID.cast(claims["jti"]),
         iat when is_integer(iat) <- claims["iat"],
         exp when is_integer(exp) <- claims["exp"],
         true <- iat <= now,
         true <- exp > now,
         :ok <- validate_not_before(claims, now) do
      :ok
    else
      _ -> {:error, :invalid_claims}
    end
  end

  defp validate_claims(_claims, _config, _now), do: {:error, :invalid_claims}

  defp validate_not_before(%{"nbf" => nbf}, now) when is_integer(nbf) and nbf <= now, do: :ok
  defp validate_not_before(%{"nbf" => _nbf}, _now), do: {:error, :invalid_claims}
  defp validate_not_before(_claims, _now), do: :ok
end
