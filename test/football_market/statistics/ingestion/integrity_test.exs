defmodule FootballMarket.Statistics.Ingestion.IntegrityTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, Statistics}
  alias FootballMarket.Statistics.Performance
  import FootballMarket.StatisticsCase

  test "legacy facts retain their default basis and raw nil positions are rejected" do
    f = fixture("PL", 2140)
    {:ok, match} = Statistics.record_match(match_attrs(f))
    {:ok, performance} = Statistics.record_performance(performance_attrs(f, match))
    assert performance.position_basis == "legacy_direct"

    attrs = performance_attrs(f, match, %{position_id: nil})

    assert_raise Postgrex.Error, fn ->
      Repo.query!(
        """
        INSERT INTO player_match_performances
          (id, match_id, player_id, team_id, season_id, position_id, minutes_played, inserted_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, now())
        """,
        [
          Ecto.UUID.dump!(Ecto.UUID.generate()),
          Ecto.UUID.dump!(attrs.match_id),
          Ecto.UUID.dump!(attrs.player_id),
          Ecto.UUID.dump!(attrs.team_id),
          Ecto.UUID.dump!(f.season.id),
          nil,
          attrs.minutes_played
        ]
      )
    end

    assert {:ok, ^match} = Statistics.get_match(match.id)
    assert {:ok, ^performance} = Statistics.get_performance(performance.player_id, match.id)

    assert_raise Postgrex.Error, fn ->
      Repo.query!(
        "UPDATE player_match_performances SET goals = 1 WHERE id = $1",
        [Ecto.UUID.dump!(performance.id)]
      )
    end

    assert_raise Postgrex.Error, fn ->
      Repo.query!(
        """
        INSERT INTO player_match_performances
          (id, match_id, player_id, team_id, season_id, position_id, minutes_played, inserted_at)
        VALUES ($1, $2, $3, $4, $5, $6, 30, now())
        """,
        [
          Ecto.UUID.dump!(Ecto.UUID.generate()),
          Ecto.UUID.dump!(match.id),
          Ecto.UUID.dump!(Ecto.UUID.generate()),
          Ecto.UUID.dump!(f.home.id),
          Ecto.UUID.dump!(f.season.id),
          Ecto.UUID.dump!(f.position.id)
        ]
      )
    end
  end

  test "raw unknown-position evidence without a validated immutable history basis is rejected" do
    f = fixture("PL", 2141)
    {:ok, match} = Statistics.record_match(match_attrs(f))
    attrs = performance_attrs(f, match, %{position_id: nil})

    changeset =
      Performance.changeset(attrs, match)
      |> Ecto.Changeset.put_change(:position_basis, "unknown_history")
      |> Ecto.Changeset.put_change(:participation, "substitute_entered")
      |> Ecto.Changeset.put_change(:position_reason, "tie")
      |> Ecto.Changeset.put_change(:position_evidence, %{
        "policy_version" => 1,
        "frequencies" => %{}
      })

    assert_raise Postgrex.Error, fn ->
      Repo.transaction(fn ->
        Repo.insert!(changeset)
        Repo.query!("SET CONSTRAINTS statistics_position_basis_validate IMMEDIATE", [])
      end)
    end

    refute Repo.exists?(from p in Performance, where: p.match_id == ^match.id)
    assert {:ok, ^match} = Statistics.get_match(match.id)
  end

  test "database guards reject SQL nulls and incomplete unknown-position evidence" do
    f = fixture("PL", 2142)
    {:ok, match} = Statistics.record_match(match_attrs(f))

    invalid_evidence = [
      {nil, "insufficient_history", %{}},
      {"substitute_entered", "insufficient_history", %{"frequencies" => %{}}},
      {"substitute_entered", "insufficient_history",
       %{"policy_version" => nil, "frequencies" => %{}}}
    ]

    for {participation, reason, evidence} <- invalid_evidence do
      assert_raise Postgrex.Error, fn ->
        Repo.transaction(fn ->
          Repo.query!(
            """
            INSERT INTO player_match_performances
              (id, match_id, player_id, team_id, season_id, position_id, minutes_played,
               position_basis, participation, position_reason, position_evidence, inserted_at)
            VALUES ($1, $2, $3, $4, $5, NULL, 30, 'unknown_history', $6, $7, $8::jsonb, now())
            """,
            [
              Ecto.UUID.dump!(Ecto.UUID.generate()),
              Ecto.UUID.dump!(match.id),
              Ecto.UUID.dump!(hd(f.players).id),
              Ecto.UUID.dump!(f.home.id),
              Ecto.UUID.dump!(f.season.id),
              participation,
              reason,
              evidence
            ]
          )

          Repo.query!("SET CONSTRAINTS statistics_position_basis_validate IMMEDIATE")
        end)
      end
    end

    evidence = %{"policy_version" => 1, "frequencies" => %{}}

    Repo.query!(
      """
      INSERT INTO player_match_performances
        (id, match_id, player_id, team_id, season_id, position_id, minutes_played,
         position_basis, participation, position_reason, position_evidence, inserted_at)
      VALUES ($1, $2, $3, $4, $5, NULL, 30, 'unknown_history',
              'substitute_entered', 'insufficient_history', $6::jsonb, now())
      """,
      [
        Ecto.UUID.dump!(Ecto.UUID.generate()),
        Ecto.UUID.dump!(match.id),
        Ecto.UUID.dump!(hd(f.players).id),
        Ecto.UUID.dump!(f.home.id),
        Ecto.UUID.dump!(f.season.id),
        evidence
      ]
    )
  end
end
