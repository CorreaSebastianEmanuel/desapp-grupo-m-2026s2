defmodule FootballMarket.Market.ConsistencyTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.Consistency

  def valid do
    [p, u, b, i, q] = for _ <- 1..5, do: Ecto.UUID.generate()
    now = DateTime.utc_now()

    %{
      player_id: p,
      recipient_id: u,
      fixed_recipient: u,
      issuance_recipients: [u],
      user_ids: [u, b],
      holdings: [%{id: Ecto.UUID.generate(), player_id: p, user_id: u, quantity: 100}],
      quotes: [
        %{
          id: q,
          player_id: p,
          unit_price: Decimal.new(1),
          effective_at: now,
          inserted_at: now,
          rule_id: "initial_issuance",
          rule_version: "1"
        }
      ],
      issuance: %{
        id: i,
        player_id: p,
        recipient_id: u,
        quantity: 100,
        initial_unit_price: Decimal.new(1),
        initial_quote_id: q,
        completed_at: now
      }
    }
  end

  test "valid retained evidence permits redistribution and extra fixture quotes" do
    s = valid()
    assert {:ok, :issued} = Consistency.validate(s)
    buyer = List.last(s.user_ids)

    for holdings <- [
          [%{hd(s.holdings) | user_id: buyer, quantity: 100}],
          [
            %{hd(s.holdings) | quantity: 0},
            %{hd(s.holdings) | id: Ecto.UUID.generate(), user_id: buyer, quantity: 100}
          ]
        ] do
      later = %{
        hd(s.quotes)
        | id: Ecto.UUID.generate(),
          rule_id: "fixture",
          unit_price: Decimal.new("9.2"),
          effective_at: DateTime.add(hd(s.quotes).effective_at, 1)
      }

      assert {:ok, :issued} =
               Consistency.validate(%{s | holdings: holdings, quotes: s.quotes ++ [later]})
    end

    assert {:ok, :unissued} =
             Consistency.validate(%{
               s
               | issuance: nil,
                 holdings: [],
                 quotes: [],
                 fixed_recipient: nil,
                 issuance_recipients: []
             })
  end

  test "adversarial holdings cannot hide invalid facts behind total 100" do
    s = valid()
    h = hd(s.holdings)

    cases = [
      [],
      [%{h | quantity: 99}],
      [%{h | quantity: 100.0}],
      [%{h | quantity: -1}],
      [
        %{h | quantity: 120},
        %{h | id: Ecto.UUID.generate(), user_id: List.last(s.user_ids), quantity: -20}
      ],
      [%{h | user_id: Ecto.UUID.generate()}],
      [%{h | player_id: Ecto.UUID.generate()}],
      [%{h | id: nil}],
      [Map.delete(h, :quantity)],
      [h, h]
    ]

    for holdings <- cases do
      assert {:error, %{kind: :inconsistent_state}} =
               Consistency.validate(%{s | holdings: holdings})
    end
  end

  test "all original facts quote linkage dates and fixed recipient must agree" do
    s = valid()
    i = s.issuance
    q = hd(s.quotes)

    for field <- Map.keys(i) do
      assert {:error, %{kind: :inconsistent_state}} =
               Consistency.validate(%{s | issuance: Map.delete(i, field)})
    end

    for {key, value} <- [
          quantity: 99,
          quantity: 100.0,
          initial_unit_price: Decimal.new(2),
          initial_unit_price: 1.0,
          player_id: Ecto.UUID.generate(),
          recipient_id: Ecto.UUID.generate(),
          initial_quote_id: Ecto.UUID.generate(),
          completed_at: DateTime.add(i.completed_at, 1),
          id: nil
        ] do
      assert {:error, %{kind: :inconsistent_state}} =
               Consistency.validate(%{s | issuance: Map.put(i, key, value)})
    end

    for field <- Map.keys(q) do
      assert {:error, %{kind: :inconsistent_state}} =
               Consistency.validate(%{s | quotes: [Map.delete(q, field)]})
    end

    for {key, value} <- [
          player_id: Ecto.UUID.generate(),
          unit_price: Decimal.new(2),
          unit_price: Decimal.new("NaN"),
          rule_id: "fixture",
          rule_version: "2",
          effective_at: nil,
          inserted_at: nil
        ] do
      assert {:error, %{kind: :inconsistent_state}} =
               Consistency.validate(%{s | quotes: [Map.put(q, key, value)]})
    end

    assert {:error, %{kind: :inconsistent_state}} =
             Consistency.validate(%{s | fixed_recipient: nil})

    assert {:error, %{kind: :recipient_conflict}} =
             Consistency.validate(%{s | fixed_recipient: List.last(s.user_ids)})

    assert {:error, %{kind: :recipient_conflict}} =
             Consistency.validate(%{s | issuance_recipients: [List.last(s.user_ids)]})

    assert {:error, %{kind: :inconsistent_state}} = Consistency.validate(%{s | quotes: []})
    assert {:error, %{kind: :inconsistent_state}} = Consistency.validate(%{s | issuance: nil})
  end

  test "partial market recipient fixation is never repaired for a fresh player" do
    s = valid()
    unissued = %{s | issuance: nil, holdings: [], quotes: []}

    assert {:error, %{kind: :inconsistent_state}} =
             Consistency.validate(%{unissued | issuance_recipients: []})

    assert {:error, %{kind: :inconsistent_state}} =
             Consistency.validate(%{unissued | fixed_recipient: nil})
  end

  test "recipient conflicts short circuit malformed retained history before coherence" do
    s = valid()

    assert {:error, %{kind: :recipient_conflict, reason: :market_recipient_conflict}} =
             Consistency.validate(%{
               s
               | fixed_recipient: List.last(s.user_ids),
                 holdings: :malformed,
                 quotes: :malformed
             })

    assert {:error, %{kind: :inconsistent_state, reason: :partial_recipient_fixation}} =
             Consistency.validate(%{
               s
               | fixed_recipient: nil,
                 holdings: :malformed,
                 quotes: :malformed
             })
  end
end
