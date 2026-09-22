defmodule FootballMarket.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field(:email, :string)
    has_one(:password_credential, FootballMarket.Accounts.PasswordCredential)
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> normalize_email()
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: "has invalid format")
    |> validate_domain()
    |> check_constraint(:email, name: :users_email_not_blank)
    |> unique_constraint(:email, name: :users_normalized_email_index)
  end

  @doc false
  def public_projection(%__MODULE__{id: id, email: email}), do: %{id: id, email: email}

  defp normalize_email(changeset) do
    case get_change(changeset, :email) do
      email when is_binary(email) ->
        put_change(changeset, :email, email |> String.trim() |> String.downcase())

      _ ->
        changeset
    end
  end

  defp validate_domain(changeset) do
    validate_change(changeset, :email, fn :email, email ->
      case String.split(email, "@") do
        [local, domain] ->
          if valid_local?(local) and valid_domain?(domain),
            do: [],
            else: [email: "has invalid format"]

        _ ->
          []
      end
    end)
  end

  defp valid_domain?(domain) do
    labels = String.split(domain, ".")

    length(labels) >= 2 and
      Enum.all?(labels, fn label ->
        String.length(label) <= 63 and
          String.length(label) > 0 and
          String.match?(label, ~r/^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/)
      end)
  end

  defp valid_local?(local) do
    String.length(local) <= 64 and
      not String.starts_with?(local, ".") and
      not String.ends_with?(local, ".") and
      not String.contains?(local, "..") and
      String.match?(local, ~r/^[a-z0-9.!#$%&'*+\/?=?^_`{|}~-]+$/i)
  end
end
