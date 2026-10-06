defmodule FootballMarket.Providers.FixturePreservationTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  # Captured independently from the pre-refactor terms, never from live fixtures.
  @baseline_sha256 %{
    "cases" => "adc0d7caca4748cf03fb82a915e83d6347b991f2b8100baee98550de810e4d74",
    "expected" => "bcbac94460cfe9df135a2306ae871c45de1b635c787f61219fdb58bcc8ccfc2c",
    "source_a" => "1274e05b86794c0297a1b7f2d77d4b232bfc6e2aa40937cd1897be9b53d782b7",
    "source_b" => "850be3ac0b7217f63d75cb679b8c90f61b260d77b308341df70355571da7d26f"
  }

  test "fixture refactor preserves all four expanded terms against independent baseline fingerprints" do
    for name <- ~w(cases expected source_a source_b) do
      path = "test/fixtures/providers/#{name}.exs"
      {current, _} = Code.eval_file(path)

      fingerprint =
        :crypto.hash(:sha256, :erlang.term_to_binary(current, [:deterministic]))
        |> Base.encode16(case: :lower)

      assert fingerprint == Map.fetch!(@baseline_sha256, name),
             "expanded fixture changed: #{path}"

      assert if(is_list(current), do: length(current), else: map_size(current)) == 217
    end
  end
end
