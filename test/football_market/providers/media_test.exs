defmodule FootballMarket.Providers.MediaTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Providers.Media

  test "public image URLs require known providers and numeric source identities" do
    assert Media.url("fotmob-public-html-v1", "player", "737066") ==
             "https://images.fotmob.com/image_resources/playerimages/737066.png"

    assert Media.url("football-data.org-v4", "team", "66") ==
             "https://crests.football-data.org/66.png"

    assert Media.url("fotmob-public-html-v1", "team", "8456") ==
             "https://images.fotmob.com/image_resources/logo/teamlogo/8456.png"

    for id <- [
          nil,
          "",
          "0",
          "../secret",
          "1?token=secret",
          "https://example.com",
          "12\n",
          "1234567890123"
        ] do
      assert is_nil(Media.url("fotmob-public-html-v1", "player", id))
    end

    assert is_nil(Media.url("unknown", "player", "12"))
    assert is_nil(Media.url("football-data.org-v4", "player", "12"))
  end
end
