defmodule FootballMarket.Accounts.BrowserSessionsTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration

  test "anonymous retirement rotates authority and expiry is exclusive" do
    user = account()
    now = ~U[2026-10-15 12:00:00.000000Z]
    {:ok, anonymous} = BrowserSessions.create_anonymous(now)
    assert {:error, :invalid} = BrowserSessions.validate(anonymous, now)
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id, now)
    assert handle != anonymous
    assert {:error, :invalid} = BrowserSessions.authenticate(anonymous, user.id, now)

    assert {:ok, actor} =
             BrowserSessions.validate(handle, DateTime.add(now, 899_999_999, :microsecond))

    assert actor.account_id == user.id
    assert {:error, :expired} = BrowserSessions.validate(handle, DateTime.add(now, 900, :second))
    assert {:error, :invalid} = BrowserSessions.validate(handle <> "tampered", now)
    assert :ok = BrowserSessions.revoke(handle, now)
    assert :ok = BrowserSessions.revoke(handle, now)
    assert {:error, :invalid} = BrowserSessions.validate(handle, now)
  end

  test "missing and malformed anonymous handles are invalid without querying persistence" do
    user = account()

    for handle <- [nil, "", "invalid", String.duplicate("!", 43)] do
      assert {:error, :invalid} = BrowserSessions.authenticate(handle, user.id)
    end
  end

  test "persistence contains only digests and independent sessions survive revocation" do
    user = account()
    now = DateTime.utc_now()
    {:ok, a} = BrowserSessions.create_anonymous(now)
    {:ok, b} = BrowserSessions.create_anonymous(now)
    {:ok, a} = BrowserSessions.authenticate(a, user.id, now)
    {:ok, b} = BrowserSessions.authenticate(b, user.id, now)
    assert :ok = BrowserSessions.revoke(a, now)
    assert {:ok, _} = BrowserSessions.validate(b, now)
    refute inspect(Repo.all(FootballMarket.Accounts.BrowserSession)) =~ b
  end

  test "missing users, outages, replay and after-boundary access fail closed" do
    controlled_clock!()
    user = account()
    now = BrowserSessions.now()
    {:ok, anonymous} = BrowserSessions.create_anonymous(now)
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id, now)
    {:ok, actor} = BrowserSessions.validate(handle, now)

    assert {:error, :expired} =
             BrowserSessions.validate(handle, DateTime.add(now, 900_000_001, :microsecond))

    assert {:ok, same} = BrowserSessions.validate(handle, DateTime.add(now, 899, :second))
    assert same.expires_at == actor.expires_at

    assert byte_size(
             Repo.get!(FootballMarket.Accounts.BrowserSession, actor.session_id).token_digest
           ) == 32

    Application.put_env(:football_market, :browser_failure, :all)
    assert {:error, :unavailable} = BrowserSessions.validate(handle, now)
    assert {:error, :unavailable} = BrowserSessions.revalidate(actor.session_id, now)
    assert {:error, :unavailable} = BrowserSessions.revoke(handle, now)
    Application.delete_env(:football_market, :browser_failure)
    import Ecto.Query

    Repo.delete_all(
      from(s in FootballMarket.Accounts.BrowserSession, where: s.user_id == ^user.id)
    )

    Repo.get!(FootballMarket.Accounts.User, user.id) |> Repo.delete!()
    assert {:error, :invalid} = BrowserSessions.validate(handle, now)
    assert :ok = BrowserSessions.revoke(nil, now)
    assert {:error, :invalid} = BrowserSessions.validate(nil, now)
  end

  test "a retired anonymous handle grants authority to at most one submission" do
    user = account()
    other = account("other@example.com")
    {:ok, anonymous} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id)
    assert {:error, :invalid} = BrowserSessions.authenticate(anonymous, other.id)
    assert {:ok, %{account_id: id}} = BrowserSessions.validate(handle)
    assert id == user.id
  end

  test "simultaneous submissions serialize retirement" do
    user = account()
    {:ok, anon} = BrowserSessions.create_anonymous()
    parent = self()

    tasks =
      for _ <- 1..2 do
        Task.async(fn ->
          send(parent, :ready)

          receive do
            :go -> BrowserSessions.authenticate(anon, user.id)
          end
        end)
      end

    for _ <- tasks, do: assert_receive(:ready)
    for task <- tasks, do: send(task.pid, :go)
    results = Enum.map(tasks, &Task.await/1)
    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &(&1 == {:error, :invalid})) == 1
  end
end
