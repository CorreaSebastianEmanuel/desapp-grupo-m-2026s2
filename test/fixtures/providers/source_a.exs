%{
  "F-C01-PL-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PL-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-PL-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PL-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-PL-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PL-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-PL-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PL-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-BL1-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "BL1", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-BL1-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-BL1-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "BL1", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-BL1-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-BL1-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "BL1", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-BL1-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-BL1-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "BL1", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-BL1-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-PD-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PD", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PD-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-PD-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PD", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PD-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-PD-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PD", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PD-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-PD-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PD", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-PD-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-SA-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "SA", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-SA-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-SA-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "SA", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-SA-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-SA-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "SA", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-SA-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-SA-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "SA", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-SA-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-FL1-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "FL1", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-FL1-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-FL1-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "FL1", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-FL1-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-FL1-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "FL1", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-FL1-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C01-FL1-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "FL1", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C01-FL1-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C02-empty" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [],
          "positions" => [],
          "players" => []
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"}
        ],
        "fixture_id" => "F-C02-empty"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C03-unknown-season" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :not_found}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C03-unsupported" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-missing-fact" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-missing-fact"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-blank-label" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{"ref" => "a/red", "season_ref" => "a/season", "name" => " ", "code" => " RED "},
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-blank-label"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-duplicate-ref-identical" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-duplicate-ref-identical"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-duplicate-ref-conflicting" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => "Other",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-duplicate-ref-conflicting"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-duplicate-source" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/first"}
        ],
        "fixture_id" => "F-C04-duplicate-source"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-duplicate-name" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => " red team ",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-duplicate-name"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-duplicate-code" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => " red "
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-duplicate-code"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-duplicate-position-name" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => " forward "}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-duplicate-position-name"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-duplicate-position-code" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "FW", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-duplicate-position-code"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-cross-season" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "other-season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-cross-season"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-dangling" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "missing",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-dangling"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-unmapped-position" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "UNKNOWN"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-unmapped-position"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-extra-normalized-field" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "rating" => 87
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-extra-normalized-field"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-binding-missing" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"}
        ],
        "fixture_id" => "F-C04-binding-missing"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-binding-dangling" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :team, "ref" => "missing", "source_id" => "safe"}
        ],
        "fixture_id" => "F-C04-binding-dangling"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-binding-duplicate" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"}
        ],
        "fixture_id" => "F-C04-binding-duplicate"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-league-mismatch" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-league-mismatch"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C04-season-mismatch" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2027
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C04-season-mismatch"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C05-same-id-other-kind" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "shared-public-id"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "shared-public-id"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C05-same-id-other-kind"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C05-same-id-other-scope" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "shared-public-id"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "shared-public-id"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C05-same-id-other-scope"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C05-same-id-other-provider" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "shared-public-id"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "shared-public-id"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C05-same-id-other-provider"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PL-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PL-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PL-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PL-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PL-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PL-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PL-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PL-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-BL1-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "BL1",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "BL1", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-BL1-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-BL1-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "BL1",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "BL1", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-BL1-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-BL1-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "BL1",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "BL1", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-BL1-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-BL1-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "BL1",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "BL1", "name" => "Bundesliga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "BL1", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-BL1-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PD-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PD",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PD", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PD-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PD-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PD",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PD", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PD-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PD-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PD",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PD", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PD-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-PD-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PD",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PD", "name" => "La Liga"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PD", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-PD-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-SA-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "SA",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "SA", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-SA-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-SA-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "SA",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "SA", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-SA-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-SA-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "SA",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "SA", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-SA-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-SA-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "SA",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "SA", "name" => "Serie A"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "SA", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-SA-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-FL1-2024-2025-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "FL1",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "FL1", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-FL1-2024-2025-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-FL1-2024-2025-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "FL1",
          "start_year" => 2024,
          "end_year" => 2025,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "FL1", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-FL1-2024-2025-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-FL1-2025-2026-A" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "FL1",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "FL1", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-FL1-2025-2026-A"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P01-FL1-2025-2026-B" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "FL1",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "FL1", "name" => "Ligue 1"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "FL1", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P01-FL1-2025-2026-B"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P02-before" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2024-12-31T23:59:59.999999Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P02-before"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P02-lower" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P02-lower"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P02-equal-offset" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T01:00:00.000000+01:00",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P02-equal-offset"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P02-upper" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000001Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P02-upper"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P02-after" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000002Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P02-after"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P03-zero" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 0,
                "shots_on_target" => 0,
                "tackles" => 0,
                "interceptions" => 0,
                "saves" => 0,
                "goals_conceded" => 0,
                "yellow_cards" => 0,
                "red_cards" => 0
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P03-zero"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P03-nil" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => nil,
                "assists" => nil,
                "shots_on_target" => nil,
                "tackles" => nil,
                "interceptions" => nil,
                "saves" => nil,
                "goals_conceded" => nil,
                "yellow_cards" => nil,
                "red_cards" => nil
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P03-nil"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P03-omitted" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{}
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P03-omitted"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P03-zero-minutes-positive-count" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 0,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P03-zero-minutes-positive-count"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P03-minutes-over-120" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 121,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P03-minutes-over-120"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P03-match-no-performance" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => []
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P03-match-no-performance"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P03-empty" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [],
          "performances" => []
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-P03-empty"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P04-filter-mixed" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            },
            %{
              "ref" => "a/excluded-scheduled",
              "season_ref" => "a/season",
              "status" => :scheduled,
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            },
            %{
              "ref" => "a/excluded-live",
              "season_ref" => "a/season",
              "status" => :live,
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            },
            %{
              "ref" => "a/excluded-postponed",
              "season_ref" => "a/season",
              "status" => :postponed,
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            },
            %{
              "ref" => "a/excluded-abandoned",
              "season_ref" => "a/season",
              "status" => :abandoned,
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            },
            %{
              "ref" => "a/old",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2024-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            },
            %{
              "ref" => "a/different-scope",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "invalid-unused",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "SA", "start_year" => 2024, "end_year" => 2025}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            },
            %{
              "ref" => "a/excluded-performance-scheduled",
              "match_ref" => "a/excluded-scheduled",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"goals" => -1}
            },
            %{
              "ref" => "a/excluded-performance-live",
              "match_ref" => "a/excluded-live",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"goals" => -1}
            },
            %{
              "ref" => "a/excluded-performance-postponed",
              "match_ref" => "a/excluded-postponed",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"goals" => -1}
            },
            %{
              "ref" => "a/excluded-performance-abandoned",
              "match_ref" => "a/excluded-abandoned",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"goals" => -1}
            },
            %{
              "ref" => "a/old-perf",
              "match_ref" => "a/old",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"goals" => -10}
            },
            %{
              "ref" => "a/different-scope-perf",
              "match_ref" => "a/different-scope",
              "player_ref" => "unused-dangling",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"goals" => -1}
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"},
          %{
            "kind" => :match,
            "ref" => "a/excluded-scheduled",
            "source_id" => "A-excluded-scheduled"
          },
          %{"kind" => :match, "ref" => "a/excluded-live", "source_id" => "A-excluded-live"},
          %{
            "kind" => :match,
            "ref" => "a/excluded-postponed",
            "source_id" => "A-excluded-postponed"
          },
          %{
            "kind" => :match,
            "ref" => "a/excluded-abandoned",
            "source_id" => "A-excluded-abandoned"
          },
          %{"kind" => :match, "ref" => "a/old", "source_id" => "A-old"},
          %{"kind" => :match, "ref" => "a/different-scope", "source_id" => "A-different-scope"}
        ],
        "fixture_id" => "F-P04-filter-mixed"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P05-bad-scope" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "ZZ", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P05-bad-scope"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P05-bad-status" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :unknown,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P05-bad-status"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P05-bad-kickoff" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P05-bad-kickoff"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P06-eligible-bad-metric" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => -1,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P06-eligible-bad-metric"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P06-eligible-duplicate" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            },
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P06-eligible-duplicate"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P06-cross-season-edge" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "different",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P06-cross-season-edge"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P06-dangling-performance-match" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "undeclared",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P06-dangling-performance-match"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P06-duplicate-eligible-ref-with-scheduled-copy" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            },
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :scheduled,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P06-duplicate-eligible-ref-with-scheduled-copy"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P07-excluded-only-directory" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => nil,
              "team_ref" => "unused-dangling",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P07-excluded-only-directory"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P07-retained-player-current-team" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            },
            %{
              "ref" => "a/green",
              "season_ref" => "a/season",
              "name" => "Green Team",
              "code" => "GRN"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/green",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"},
          %{"kind" => :team, "ref" => "a/green", "source_id" => "A-source-a/green"}
        ],
        "fixture_id" => "F-P07-retained-player-current-team"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P08-transfer" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P08-transfer"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P09-no-capability" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => -1,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0.5,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => true,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => "1",
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-assists-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => -1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-assists-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-assists-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 0.5,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-assists-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-assists-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => true,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-assists-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-assists-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => "1",
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-assists-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-shots_on_target-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => -1,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-shots_on_target-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-shots_on_target-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 0.5,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-shots_on_target-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-shots_on_target-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => true,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-shots_on_target-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-shots_on_target-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => "1",
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-shots_on_target-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-tackles-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => -1,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-tackles-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-tackles-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 0.5,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-tackles-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-tackles-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => true,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-tackles-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-tackles-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => "1",
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-tackles-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-interceptions-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => -1,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-interceptions-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-interceptions-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 0.5,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-interceptions-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-interceptions-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => true,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-interceptions-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-interceptions-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => "1",
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-interceptions-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-saves-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => -1,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-saves-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-saves-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 0.5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-saves-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-saves-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => true,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-saves-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-saves-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => "1",
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-saves-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals_conceded-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => -1,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals_conceded-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals_conceded-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 0.5,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals_conceded-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals_conceded-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => true,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals_conceded-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-goals_conceded-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => "1",
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-goals_conceded-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-yellow_cards-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => -1,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-yellow_cards-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-yellow_cards-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 0.5,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-yellow_cards-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-yellow_cards-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => true,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-yellow_cards-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-yellow_cards-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => "1",
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-yellow_cards-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-red_cards-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => -1
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-red_cards-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-red_cards-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 0.5
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-red_cards-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-red_cards-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => true
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-red_cards-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-red_cards-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => "1"
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-red_cards-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-minutes_played-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => -1,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-minutes_played-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-minutes_played-fraction" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 0.5,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-minutes_played-fraction"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-minutes_played-boolean" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => true,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-minutes_played-boolean"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-minutes_played-text" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => "1",
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-minutes_played-text"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-unsupported-count" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8,
                "rating" => 10
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-unsupported-count"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-missing-minutes" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-missing-minutes"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-missing-kickoff" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-missing-kickoff"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-missing-position" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "unmapped",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-missing-position"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-unknown-league" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "ZZ", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-unknown-league"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-missing-participant" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "absent",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-missing-participant"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-same-home-away" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/red",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-same-home-away"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-nonparticipating-team" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            },
            %{
              "ref" => "a/green",
              "season_ref" => "a/season",
              "name" => "Green Team",
              "code" => "GRN"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/green",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/green",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"},
          %{"kind" => :team, "ref" => "a/green", "source_id" => "A-source-a/green"}
        ],
        "fixture_id" => "F-P10-nonparticipating-team"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-repeat-player-match" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            },
            %{
              "ref" => "another",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-repeat-player-match"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-duplicate-identical" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            },
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-duplicate-identical"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-duplicate-conflicting" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            },
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 20,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-duplicate-conflicting"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-rating-substitute" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"rating" => 10}
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-rating-substitute"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-P10-team-total-substitute" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{"team_goals" => 10}
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-P10-team-total-substitute"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R01-case" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-R01-case"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R01-whitespace" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-R01-whitespace"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R01-string-keys" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-R01-string-keys"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-missing" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-unknown-field" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-mixed-keys" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-non-map" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-league" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-year-type" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-year-bool" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-year-gap" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-catalog-bound" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-timeout-type" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-timeout-zero" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-timeout-negative" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R02-timeout-bool" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R03-same-year" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-R03-same-year"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R03-lower-only" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-R03-lower-only"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R03-upper-only" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-R03-upper-only"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R03-unbounded" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-R03-unbounded"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R03-offset-equal" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :performances,
        "scope" => %{
          "league_code" => "PL",
          "start_year" => 2025,
          "end_year" => 2026,
          "from" => nil,
          "to" => nil
        },
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ],
          "matches" => [
            %{
              "ref" => "a/match",
              "season_ref" => "a/season",
              "status" => :completed,
              "kickoff_at" => "2025-01-01T00:00:00.000000Z",
              "home_team_ref" => "a/red",
              "away_team_ref" => "a/blue",
              "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026}
            }
          ],
          "performances" => [
            %{
              "ref" => "a/appearance",
              "match_ref" => "a/match",
              "player_ref" => "a/first",
              "team_ref" => "a/red",
              "position_ref" => "FW",
              "minutes_played" => 91,
              "counts" => %{
                "goals" => 0,
                "assists" => 1,
                "shots_on_target" => 2,
                "tackles" => 3,
                "interceptions" => 4,
                "saves" => 5,
                "goals_conceded" => 6,
                "yellow_cards" => 7,
                "red_cards" => 8
              }
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"},
          %{"kind" => :match, "ref" => "a/match", "source_id" => "A-source-a/match"}
        ],
        "fixture_id" => "F-R03-offset-equal"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R04-naive" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R04-bad-instant" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R04-overprecision" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-R04-reversed" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-invalid_request" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-invalid_request" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-unsupported_capability" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-unsupported_capability" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unsupported_capability}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-not_found" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :not_found}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-not_found" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :not_found}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-authentication_failed" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :authentication_failed}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-authentication_failed" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :authentication_failed}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-rate_limited" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-rate_limited" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-unavailable" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unavailable}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-unavailable" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unavailable}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-timeout" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-timeout" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E01-invalid_response" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_response}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-I01-invalid_response" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_response}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E02-known-delay" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited, "retry_after_ms" => 17}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E02-unknown-delay" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited, "retry_after_ms" => nil}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E02-bad-delay" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :rate_limited, "retry_after_ms" => -1}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-url" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{
            "kind" => :league,
            "ref" => "a/league",
            "source_id" => "https://FAKE_SENTINEL.invalid/a"
          },
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-E03-url"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-userinfo" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{
            "kind" => :league,
            "ref" => "a/league",
            "source_id" => "https://FAKE_SENTINEL:pw@invalid/a"
          },
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-E03-userinfo"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-token-query" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{
            "kind" => :league,
            "ref" => "a/league",
            "source_id" => "https://invalid/?token=FAKE_SENTINEL"
          },
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-E03-token-query"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-header" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{
            "kind" => :league,
            "ref" => "a/league",
            "source_id" => "Authorization: Bearer FAKE_SENTINEL"
          },
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-E03-header"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-source-ref" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "Bearer FAKE_SENTINEL",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-E03-source-ref"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-source-id" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "token=FAKE_SENTINEL"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-E03-source-id"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-fixture-id" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "password: FAKE_SENTINEL"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-exception" => %{
    "document" => %{"candidate" => %{"throw" => true}, "elapsed_us" => 0, "portions" => []},
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-unknown-key" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :invalid_request}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-E03-provider-label" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "Authorization: FAKE_SENTINEL"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D01-default-before" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D01-default-before"
      },
      "elapsed_us" => 4_999_999,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D01-default-at" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D01-default-at"
      },
      "elapsed_us" => 5_000_000,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D01-default-after" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D01-default-after"
      },
      "elapsed_us" => 5_000_001,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D01-default-never" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D01-default-never"
      },
      "elapsed_us" => 10_000_000,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D02-custom-before" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D02-custom-before"
      },
      "elapsed_us" => 6999,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D02-custom-at" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D02-custom-at"
      },
      "elapsed_us" => 7000,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D02-custom-after" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D02-custom-after"
      },
      "elapsed_us" => 7001,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D02-custom-validation-delay" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D02-custom-validation-delay"
      },
      "elapsed_us" => 6999,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D02-custom-error-at-boundary" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 7000,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D03-pages-complete" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => []
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D03-pages-complete"
      },
      "elapsed_us" => 0,
      "portions" => [
        %{
          "delay_us" => 1000,
          "facts" => %{
            "players" => [
              %{
                "ref" => "a/first",
                "season_ref" => "a/season",
                "display_name" => " Alex Example ",
                "team_ref" => "a/red",
                "position_ref" => "FW"
              }
            ]
          }
        },
        %{
          "delay_us" => 2000,
          "facts" => %{
            "players" => [
              %{
                "ref" => "a/second",
                "season_ref" => "a/season",
                "display_name" => "Alex Example",
                "team_ref" => "a/blue",
                "position_ref" => "GK"
              }
            ]
          }
        }
      ]
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D04-later-page-error" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => []
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D04-later-page-error"
      },
      "elapsed_us" => 0,
      "portions" => [
        %{
          "delay_us" => 1000,
          "facts" => %{
            "players" => [
              %{
                "ref" => "a/first",
                "season_ref" => "a/season",
                "display_name" => " Alex Example ",
                "team_ref" => "a/red",
                "position_ref" => "FW"
              }
            ]
          }
        },
        %{"delay_us" => 1000, "failure" => %{"category" => :unavailable}}
      ]
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D04-later-page-timeout" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => []
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D04-later-page-timeout"
      },
      "elapsed_us" => 0,
      "portions" => [
        %{
          "delay_us" => 2000,
          "facts" => %{
            "players" => [
              %{
                "ref" => "a/first",
                "season_ref" => "a/season",
                "display_name" => " Alex Example ",
                "team_ref" => "a/red",
                "position_ref" => "FW"
              }
            ]
          }
        },
        %{
          "delay_us" => 5000,
          "facts" => %{
            "players" => [
              %{
                "ref" => "a/second",
                "season_ref" => "a/season",
                "display_name" => "Alex Example",
                "team_ref" => "a/blue",
                "position_ref" => "GK"
              }
            ]
          }
        }
      ]
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D04-cumulative-page-delay" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => []
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-D04-cumulative-page-delay"
      },
      "elapsed_us" => 0,
      "portions" => [
        %{
          "delay_us" => 4000,
          "facts" => %{
            "players" => [
              %{
                "ref" => "a/first",
                "season_ref" => "a/season",
                "display_name" => " Alex Example ",
                "team_ref" => "a/red",
                "position_ref" => "FW"
              }
            ]
          }
        },
        %{
          "delay_us" => 4000,
          "facts" => %{
            "players" => [
              %{
                "ref" => "a/second",
                "season_ref" => "a/season",
                "display_name" => "Alex Example",
                "team_ref" => "a/blue",
                "position_ref" => "GK"
              }
            ]
          }
        }
      ]
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D05-late-result" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D05-next-call" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D05-caller-exit" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :timeout}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-D05-crash" => %{
    "document" => %{
      "candidate" => %{"failure" => %{"category" => :unavailable}},
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-O01-repeat" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-O01-repeat"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-O02-bijection-negative" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-O02-bijection-negative"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-O03-traceability" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2025,
            "end_year" => 2026
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "A-source-a/league"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "A-source-a/season"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-O03-traceability"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  },
  "F-C05-same-id-other-scope-2024" => %{
    "document" => %{
      "candidate" => %{
        "operation" => :catalog,
        "scope" => %{"league_code" => "PL", "start_year" => 2024, "end_year" => 2025},
        "facts" => %{
          "league" => %{"ref" => "a/league", "code" => "PL", "name" => "Premier League"},
          "season" => %{
            "ref" => "a/season",
            "league_ref" => "a/league",
            "start_year" => 2024,
            "end_year" => 2025
          },
          "teams" => [
            %{
              "ref" => "a/red",
              "season_ref" => "a/season",
              "name" => " Red Team ",
              "code" => " RED "
            },
            %{
              "ref" => "a/blue",
              "season_ref" => "a/season",
              "name" => "Blue Team",
              "code" => "BLU"
            }
          ],
          "positions" => [
            %{"ref" => "FW", "code" => "FW", "name" => "Forward"},
            %{"ref" => "GK", "code" => "GK", "name" => "Goalkeeper"}
          ],
          "players" => [
            %{
              "ref" => "a/first",
              "season_ref" => "a/season",
              "display_name" => " Alex Example ",
              "team_ref" => "a/red",
              "position_ref" => "FW"
            },
            %{
              "ref" => "a/second",
              "season_ref" => "a/season",
              "display_name" => "Alex Example",
              "team_ref" => "a/blue",
              "position_ref" => "GK"
            }
          ]
        },
        "bindings" => [
          %{"kind" => :league, "ref" => "a/league", "source_id" => "shared-public-id"},
          %{"kind" => :season, "ref" => "a/season", "source_id" => "shared-public-id"},
          %{"kind" => :team, "ref" => "a/red", "source_id" => "A-source-a/red"},
          %{"kind" => :team, "ref" => "a/blue", "source_id" => "A-source-a/blue"},
          %{"kind" => :player, "ref" => "a/first", "source_id" => "A-source-a/first"},
          %{"kind" => :player, "ref" => "a/second", "source_id" => "A-source-a/second"}
        ],
        "fixture_id" => "F-C05-same-id-other-scope-2024"
      },
      "elapsed_us" => 0,
      "portions" => []
    },
    "ignored_vendor_rating" => 9876,
    "ignored_team_goals" => 999,
    "ignored_attempted_tackles" => 888
  }
}
