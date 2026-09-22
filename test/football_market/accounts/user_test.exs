defmodule FootballMarket.Accounts.UserTest do
  use ExUnit.Case, async: true

  alias FootballMarket.Accounts.User

  test "normalizes valid email identity by trimming and lowercasing" do
    changeset = User.changeset(%User{}, %{email: "  PERSON@Example.Test  "})

    assert changeset.valid?
    assert Ecto.Changeset.get_change(changeset, :email) == "person@example.test"
  end

  test "rejects blank, whitespace, malformed, and whitespace-containing addresses" do
    for email <- [
          nil,
          "",
          "   ",
          "person",
          "@example.test",
          "person@",
          "person @example.test",
          "person@example",
          ".person@example.test",
          "person..name@example.test",
          "person@-example.test",
          "person@example-.test"
        ] do
      refute User.changeset(%User{}, %{email: email}).valid?,
             "expected #{inspect(email)} to be invalid"
    end
  end
end
