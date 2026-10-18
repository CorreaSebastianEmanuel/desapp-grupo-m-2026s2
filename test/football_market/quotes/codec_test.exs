defmodule FootballMarket.Quotes.CodecTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  alias FootballMarket.Quotes.EvidenceCodec
  alias FootballMarket.ValuationCase

  test "typed fact evidence round-trips and rejects unknown keys" do
    fact = ValuationCase.fact(17)
    encoded = EvidenceCodec.encode_facts([fact])
    assert {:ok, [decoded]} = EvidenceCodec.decode_facts(encoded)
    assert decoded == fact

    assert {:error, :invalid_evidence} =
             EvidenceCodec.decode_facts([Map.put(hd(encoded), "executable", "no")])
  end

  test "decoder only accepts known metric names and integer values" do
    encoded = EvidenceCodec.encode_facts([ValuationCase.fact(18)])
    [fact] = encoded
    metrics = Map.put(fact["metrics"], "unknown_metric", 1)

    assert {:error, :invalid_evidence} =
             EvidenceCodec.decode_facts([Map.put(fact, "metrics", metrics)])

    invalid = Map.put(fact["metrics"], "goals", "one")

    assert {:error, :invalid_evidence} =
             EvidenceCodec.decode_facts([Map.put(fact, "metrics", invalid)])
  end
end
