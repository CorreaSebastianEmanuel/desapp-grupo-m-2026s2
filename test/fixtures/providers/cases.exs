[
  %{
    :id => "F-C01-PL-2024-2025-A",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PL-2024-2025-A", :b => "F-C01-PL-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-PL-2024-2025-B",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PL-2024-2025-B", :b => "F-C01-PL-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-PL-2025-2026-A",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PL-2025-2026-A", :b => "F-C01-PL-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-PL-2025-2026-B",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PL-2025-2026-B", :b => "F-C01-PL-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-BL1-2024-2025-A",
    :operation => :catalog,
    :request => %{:league_code => "BL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-BL1-2024-2025-A", :b => "F-C01-BL1-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "BL1", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-BL1-2024-2025-B",
    :operation => :catalog,
    :request => %{:league_code => "BL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-BL1-2024-2025-B", :b => "F-C01-BL1-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "BL1", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-BL1-2025-2026-A",
    :operation => :catalog,
    :request => %{:league_code => "BL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-BL1-2025-2026-A", :b => "F-C01-BL1-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "BL1", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-BL1-2025-2026-B",
    :operation => :catalog,
    :request => %{:league_code => "BL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-BL1-2025-2026-B", :b => "F-C01-BL1-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "BL1", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-PD-2024-2025-A",
    :operation => :catalog,
    :request => %{:league_code => "PD", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PD-2024-2025-A", :b => "F-C01-PD-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PD", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-PD-2024-2025-B",
    :operation => :catalog,
    :request => %{:league_code => "PD", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PD-2024-2025-B", :b => "F-C01-PD-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PD", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-PD-2025-2026-A",
    :operation => :catalog,
    :request => %{:league_code => "PD", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PD-2025-2026-A", :b => "F-C01-PD-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PD", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-PD-2025-2026-B",
    :operation => :catalog,
    :request => %{:league_code => "PD", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-PD-2025-2026-B", :b => "F-C01-PD-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "PD", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-SA-2024-2025-A",
    :operation => :catalog,
    :request => %{:league_code => "SA", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-SA-2024-2025-A", :b => "F-C01-SA-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "SA", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-SA-2024-2025-B",
    :operation => :catalog,
    :request => %{:league_code => "SA", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-SA-2024-2025-B", :b => "F-C01-SA-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "SA", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-SA-2025-2026-A",
    :operation => :catalog,
    :request => %{:league_code => "SA", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-SA-2025-2026-A", :b => "F-C01-SA-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "SA", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-SA-2025-2026-B",
    :operation => :catalog,
    :request => %{:league_code => "SA", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-SA-2025-2026-B", :b => "F-C01-SA-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "SA", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-FL1-2024-2025-A",
    :operation => :catalog,
    :request => %{:league_code => "FL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-FL1-2024-2025-A", :b => "F-C01-FL1-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "FL1", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-FL1-2024-2025-B",
    :operation => :catalog,
    :request => %{:league_code => "FL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-FL1-2024-2025-B", :b => "F-C01-FL1-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "FL1", :start_year => 2024, :end_year => 2025}
  },
  %{
    :id => "F-C01-FL1-2025-2026-A",
    :operation => :catalog,
    :request => %{:league_code => "FL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-FL1-2025-2026-A", :b => "F-C01-FL1-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "FL1", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C01-FL1-2025-2026-B",
    :operation => :catalog,
    :request => %{:league_code => "FL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C01-FL1-2025-2026-B", :b => "F-C01-FL1-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-001", "FR-004", "FR-005", "FR-008", "FR-012", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{:league_code => "FL1", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C02-empty",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C02-empty", :b => "F-C02-empty"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.2"],
    :requirements => ["FR-003"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C03-unknown-season",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C03-unknown-season", :b => "F-C03-unknown-season"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.2"],
    :requirements => ["FR-003", "FR-009"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C03-unsupported",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C03-unsupported", :b => "F-C03-unsupported"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.2"],
    :requirements => ["FR-003", "FR-009"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-missing-fact",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-missing-fact", :b => "F-C04-missing-fact"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-blank-label",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-blank-label", :b => "F-C04-blank-label"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-duplicate-ref-identical",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-duplicate-ref-identical", :b => "F-C04-duplicate-ref-identical"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-duplicate-ref-conflicting",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{
      :a => "F-C04-duplicate-ref-conflicting",
      :b => "F-C04-duplicate-ref-conflicting"
    },
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-duplicate-source",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-duplicate-source", :b => "F-C04-duplicate-source"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-duplicate-name",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-duplicate-name", :b => "F-C04-duplicate-name"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-duplicate-code",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-duplicate-code", :b => "F-C04-duplicate-code"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-duplicate-position-name",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-duplicate-position-name", :b => "F-C04-duplicate-position-name"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-duplicate-position-code",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-duplicate-position-code", :b => "F-C04-duplicate-position-code"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-cross-season",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-cross-season", :b => "F-C04-cross-season"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-dangling",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-dangling", :b => "F-C04-dangling"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-unmapped-position",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-unmapped-position", :b => "F-C04-unmapped-position"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-extra-normalized-field",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-extra-normalized-field", :b => "F-C04-extra-normalized-field"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-binding-missing",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-binding-missing", :b => "F-C04-binding-missing"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-binding-dangling",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-binding-dangling", :b => "F-C04-binding-dangling"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-binding-duplicate",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-binding-duplicate", :b => "F-C04-binding-duplicate"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-league-mismatch",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-league-mismatch", :b => "F-C04-league-mismatch"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C04-season-mismatch",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C04-season-mismatch", :b => "F-C04-season-mismatch"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.4"],
    :requirements => ["FR-004", "FR-005", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C05-same-id-other-kind",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C05-same-id-other-kind", :b => "F-C05-same-id-other-kind"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "a/season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "b#season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-005"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C05-same-id-other-scope",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C05-same-id-other-scope", :b => "F-C05-same-id-other-scope"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "a/season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "b#season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-005"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C05-same-id-other-provider",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C05-same-id-other-provider", :b => "F-C05-same-id-other-provider"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "a/season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "b#season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-005"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-P01-PL-2024-2025-A",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PL-2024-2025-A", :b => "F-P01-PL-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-PL-2024-2025-B",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PL-2024-2025-B", :b => "F-P01-PL-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-PL-2025-2026-A",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PL-2025-2026-A", :b => "F-P01-PL-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-PL-2025-2026-B",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PL-2025-2026-B", :b => "F-P01-PL-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-BL1-2024-2025-A",
    :operation => :performances,
    :request => %{:league_code => "BL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-BL1-2024-2025-A", :b => "F-P01-BL1-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "BL1",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-BL1-2024-2025-B",
    :operation => :performances,
    :request => %{:league_code => "BL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-BL1-2024-2025-B", :b => "F-P01-BL1-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "BL1",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-BL1-2025-2026-A",
    :operation => :performances,
    :request => %{:league_code => "BL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-BL1-2025-2026-A", :b => "F-P01-BL1-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "BL1",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-BL1-2025-2026-B",
    :operation => :performances,
    :request => %{:league_code => "BL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-BL1-2025-2026-B", :b => "F-P01-BL1-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "BL1",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-PD-2024-2025-A",
    :operation => :performances,
    :request => %{:league_code => "PD", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PD-2024-2025-A", :b => "F-P01-PD-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PD",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-PD-2024-2025-B",
    :operation => :performances,
    :request => %{:league_code => "PD", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PD-2024-2025-B", :b => "F-P01-PD-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PD",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-PD-2025-2026-A",
    :operation => :performances,
    :request => %{:league_code => "PD", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PD-2025-2026-A", :b => "F-P01-PD-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PD",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-PD-2025-2026-B",
    :operation => :performances,
    :request => %{:league_code => "PD", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-PD-2025-2026-B", :b => "F-P01-PD-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "PD",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-SA-2024-2025-A",
    :operation => :performances,
    :request => %{:league_code => "SA", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-SA-2024-2025-A", :b => "F-P01-SA-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "SA",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-SA-2024-2025-B",
    :operation => :performances,
    :request => %{:league_code => "SA", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-SA-2024-2025-B", :b => "F-P01-SA-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "SA",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-SA-2025-2026-A",
    :operation => :performances,
    :request => %{:league_code => "SA", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-SA-2025-2026-A", :b => "F-P01-SA-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "SA",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-SA-2025-2026-B",
    :operation => :performances,
    :request => %{:league_code => "SA", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-SA-2025-2026-B", :b => "F-P01-SA-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "SA",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-FL1-2024-2025-A",
    :operation => :performances,
    :request => %{:league_code => "FL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-FL1-2024-2025-A", :b => "F-P01-FL1-2024-2025-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "FL1",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-FL1-2024-2025-B",
    :operation => :performances,
    :request => %{:league_code => "FL1", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-FL1-2024-2025-B", :b => "F-P01-FL1-2024-2025-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "FL1",
      :start_year => 2024,
      :end_year => 2025,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-FL1-2025-2026-A",
    :operation => :performances,
    :request => %{:league_code => "FL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-FL1-2025-2026-A", :b => "F-P01-FL1-2025-2026-A"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "FL1",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P01-FL1-2025-2026-B",
    :operation => :performances,
    :request => %{:league_code => "FL1", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P01-FL1-2025-2026-B", :b => "F-P01-FL1-2025-2026-B"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US4.2"],
    :requirements => ["FR-001", "FR-005", "FR-006", "FR-007", "FR-013"],
    :success_criteria => ["SC-001", "SC-005"],
    :expected_scope => %{
      :league_code => "FL1",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P02-before",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P02-before", :b => "F-P02-before"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002", "FR-006"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    }
  },
  %{
    :id => "F-P02-lower",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P02-lower", :b => "F-P02-lower"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002", "FR-006"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    }
  },
  %{
    :id => "F-P02-equal-offset",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P02-equal-offset", :b => "F-P02-equal-offset"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002", "FR-006"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    }
  },
  %{
    :id => "F-P02-upper",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P02-upper", :b => "F-P02-upper"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002", "FR-006"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    }
  },
  %{
    :id => "F-P02-after",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P02-after", :b => "F-P02-after"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002", "FR-006"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000001Z"
    }
  },
  %{
    :id => "F-P03-zero",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P03-zero", :b => "F-P03-zero"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.2"],
    :requirements => ["FR-003", "FR-007"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P03-nil",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P03-nil", :b => "F-P03-nil"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.2"],
    :requirements => ["FR-003", "FR-007"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P03-omitted",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P03-omitted", :b => "F-P03-omitted"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.2"],
    :requirements => ["FR-003", "FR-007"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P03-zero-minutes-positive-count",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{
      :a => "F-P03-zero-minutes-positive-count",
      :b => "F-P03-zero-minutes-positive-count"
    },
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.2"],
    :requirements => ["FR-003", "FR-007"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P03-minutes-over-120",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P03-minutes-over-120", :b => "F-P03-minutes-over-120"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.2"],
    :requirements => ["FR-003", "FR-007"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P03-match-no-performance",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P03-match-no-performance", :b => "F-P03-match-no-performance"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{},
        :player => %{},
        :match => %{"a/match" => "match"},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{},
        :player => %{},
        :match => %{"b#match" => "match"},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.2"],
    :requirements => ["FR-003", "FR-007"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P03-empty",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P03-empty", :b => "F-P03-empty"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{},
        :position => %{},
        :player => %{},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.2"],
    :requirements => ["FR-003", "FR-007"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P04-filter-mixed",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P04-filter-mixed", :b => "F-P04-filter-mixed"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-006", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => nil
    }
  },
  %{
    :id => "F-P05-bad-scope",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P05-bad-scope", :b => "F-P05-bad-scope"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US2.5"],
    :requirements => ["FR-006", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P05-bad-status",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P05-bad-status", :b => "F-P05-bad-status"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US2.5"],
    :requirements => ["FR-006", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P05-bad-kickoff",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P05-bad-kickoff", :b => "F-P05-bad-kickoff"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US2.5"],
    :requirements => ["FR-006", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P06-eligible-bad-metric",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P06-eligible-bad-metric", :b => "F-P06-eligible-bad-metric"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P06-eligible-duplicate",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P06-eligible-duplicate", :b => "F-P06-eligible-duplicate"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P06-cross-season-edge",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P06-cross-season-edge", :b => "F-P06-cross-season-edge"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P06-dangling-performance-match",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{
      :a => "F-P06-dangling-performance-match",
      :b => "F-P06-dangling-performance-match"
    },
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P06-duplicate-eligible-ref-with-scheduled-copy",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{
      :a => "F-P06-duplicate-eligible-ref-with-scheduled-copy",
      :b => "F-P06-duplicate-eligible-ref-with-scheduled-copy"
    },
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P07-excluded-only-directory",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P07-excluded-only-directory", :b => "F-P07-excluded-only-directory"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US2.3"],
    :requirements => ["FR-004", "FR-006", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P07-retained-player-current-team",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{
      :a => "F-P07-retained-player-current-team",
      :b => "F-P07-retained-player-current-team"
    },
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue", "a/green" => "green"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue", "b#green" => "green"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :team, :ref => "a/green", :source_id => "A-source-a/green"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :team, :ref => "b#green", :source_id => "B-source-b#green"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1", "US2.3"],
    :requirements => ["FR-004", "FR-006", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P08-transfer",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P08-transfer", :b => "F-P08-transfer"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.3"],
    :requirements => ["FR-006"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P09-no-capability",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P09-no-capability", :b => "F-P09-no-capability"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.4"],
    :requirements => ["FR-006", "FR-009"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals-negative", :b => "F-P10-goals-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals-fraction", :b => "F-P10-goals-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals-boolean", :b => "F-P10-goals-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals-text", :b => "F-P10-goals-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-assists-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-assists-negative", :b => "F-P10-assists-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-assists-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-assists-fraction", :b => "F-P10-assists-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-assists-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-assists-boolean", :b => "F-P10-assists-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-assists-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-assists-text", :b => "F-P10-assists-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-shots_on_target-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-shots_on_target-negative", :b => "F-P10-shots_on_target-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-shots_on_target-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-shots_on_target-fraction", :b => "F-P10-shots_on_target-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-shots_on_target-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-shots_on_target-boolean", :b => "F-P10-shots_on_target-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-shots_on_target-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-shots_on_target-text", :b => "F-P10-shots_on_target-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-tackles-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-tackles-negative", :b => "F-P10-tackles-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-tackles-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-tackles-fraction", :b => "F-P10-tackles-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-tackles-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-tackles-boolean", :b => "F-P10-tackles-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-tackles-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-tackles-text", :b => "F-P10-tackles-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-interceptions-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-interceptions-negative", :b => "F-P10-interceptions-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-interceptions-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-interceptions-fraction", :b => "F-P10-interceptions-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-interceptions-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-interceptions-boolean", :b => "F-P10-interceptions-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-interceptions-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-interceptions-text", :b => "F-P10-interceptions-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-saves-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-saves-negative", :b => "F-P10-saves-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-saves-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-saves-fraction", :b => "F-P10-saves-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-saves-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-saves-boolean", :b => "F-P10-saves-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-saves-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-saves-text", :b => "F-P10-saves-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals_conceded-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals_conceded-negative", :b => "F-P10-goals_conceded-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals_conceded-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals_conceded-fraction", :b => "F-P10-goals_conceded-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals_conceded-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals_conceded-boolean", :b => "F-P10-goals_conceded-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-goals_conceded-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-goals_conceded-text", :b => "F-P10-goals_conceded-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-yellow_cards-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-yellow_cards-negative", :b => "F-P10-yellow_cards-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-yellow_cards-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-yellow_cards-fraction", :b => "F-P10-yellow_cards-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-yellow_cards-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-yellow_cards-boolean", :b => "F-P10-yellow_cards-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-yellow_cards-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-yellow_cards-text", :b => "F-P10-yellow_cards-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-red_cards-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-red_cards-negative", :b => "F-P10-red_cards-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-red_cards-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-red_cards-fraction", :b => "F-P10-red_cards-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-red_cards-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-red_cards-boolean", :b => "F-P10-red_cards-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-red_cards-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-red_cards-text", :b => "F-P10-red_cards-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-minutes_played-negative",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-minutes_played-negative", :b => "F-P10-minutes_played-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-minutes_played-fraction",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-minutes_played-fraction", :b => "F-P10-minutes_played-fraction"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-minutes_played-boolean",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-minutes_played-boolean", :b => "F-P10-minutes_played-boolean"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-minutes_played-text",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-minutes_played-text", :b => "F-P10-minutes_played-text"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-unsupported-count",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-unsupported-count", :b => "F-P10-unsupported-count"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-missing-minutes",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-missing-minutes", :b => "F-P10-missing-minutes"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-missing-kickoff",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-missing-kickoff", :b => "F-P10-missing-kickoff"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-missing-position",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-missing-position", :b => "F-P10-missing-position"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-unknown-league",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-unknown-league", :b => "F-P10-unknown-league"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-missing-participant",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-missing-participant", :b => "F-P10-missing-participant"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-same-home-away",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-same-home-away", :b => "F-P10-same-home-away"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-nonparticipating-team",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-nonparticipating-team", :b => "F-P10-nonparticipating-team"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-repeat-player-match",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-repeat-player-match", :b => "F-P10-repeat-player-match"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-duplicate-identical",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-duplicate-identical", :b => "F-P10-duplicate-identical"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-duplicate-conflicting",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-duplicate-conflicting", :b => "F-P10-duplicate-conflicting"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-rating-substitute",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-rating-substitute", :b => "F-P10-rating-substitute"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-P10-team-total-substitute",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-P10-team-total-substitute", :b => "F-P10-team-total-substitute"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.5"],
    :requirements => ["FR-006", "FR-007", "FR-008"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-R01-case",
    :operation => :catalog,
    :request => %{:league_code => "pl", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R01-case", :b => "F-R01-case"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-R01-whitespace",
    :operation => :catalog,
    :request => %{:league_code => " PL ", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R01-whitespace", :b => "F-R01-whitespace"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-R01-string-keys",
    :operation => :catalog,
    :request => %{"league_code" => "PL", "start_year" => 2025, "end_year" => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R01-string-keys", :b => "F-R01-string-keys"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-R02-missing",
    :operation => :catalog,
    :request => %{:start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-missing", :b => "F-R02-missing"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-unknown-field",
    :operation => :catalog,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      "FAKE_SENTINEL" => "bad"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-unknown-field", :b => "F-R02-unknown-field"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-mixed-keys",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, "to" => nil},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-mixed-keys", :b => "F-R02-mixed-keys"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-non-map",
    :operation => :catalog,
    :request => true,
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-non-map", :b => "F-R02-non-map"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-league",
    :operation => :catalog,
    :request => %{:league_code => "ZZ", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-league", :b => "F-R02-league"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-year-type",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => "2025", :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-year-type", :b => "F-R02-year-type"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-year-bool",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => true, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-year-bool", :b => "F-R02-year-bool"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-year-gap",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2028},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-year-gap", :b => "F-R02-year-gap"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-catalog-bound",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :from => nil},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-catalog-bound", :b => "F-R02-catalog-bound"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R02-timeout-type",
    :operation => :catalog,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :timeout_ms => "7"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-timeout-type", :b => "F-R02-timeout-type"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-009", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-R02-timeout-zero",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 0},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-timeout-zero", :b => "F-R02-timeout-zero"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-009", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-R02-timeout-negative",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => -1},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-timeout-negative", :b => "F-R02-timeout-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-009", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-R02-timeout-bool",
    :operation => :catalog,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :timeout_ms => true
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R02-timeout-bool", :b => "F-R02-timeout-bool"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3"],
    :requirements => ["FR-002", "FR-009", "FR-010"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-R03-same-year",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R03-same-year", :b => "F-R03-same-year"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2025}
  },
  %{
    :id => "F-R03-lower-only",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R03-lower-only", :b => "F-R03-lower-only"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => nil
    }
  },
  %{
    :id => "F-R03-upper-only",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :to => "2025-01-01T00:00:00.000000Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R03-upper-only", :b => "F-R03-upper-only"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => "2025-01-01T00:00:00.000000Z"
    }
  },
  %{
    :id => "F-R03-unbounded",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R03-unbounded", :b => "F-R03-unbounded"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => nil,
      :to => nil
    }
  },
  %{
    :id => "F-R03-offset-equal",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T01:00:00.000000+01:00",
      :to => "2025-01-01T00:00:00.000000Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R03-offset-equal", :b => "F-R03-offset-equal"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.000000Z",
      :to => "2025-01-01T00:00:00.000000Z"
    }
  },
  %{
    :id => "F-R04-naive",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R04-naive", :b => "F-R04-naive"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3", "US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R04-bad-instant",
    :operation => :performances,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :from => "no"},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R04-bad-instant", :b => "F-R04-bad-instant"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3", "US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R04-overprecision",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-01-01T00:00:00.1234567Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R04-overprecision", :b => "F-R04-overprecision"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3", "US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-R04-reversed",
    :operation => :performances,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      :from => "2025-02-01T00:00:00Z",
      :to => "2025-01-01T00:00:00.000000Z"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-R04-reversed", :b => "F-R04-reversed"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{"a/match" => "match"},
        :performance => %{"a/appearance" => "appearance"}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{"b#match" => "match"},
        :performance => %{"b#appearance" => "appearance"}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"},
        %{:kind => :match, :ref => "a/match", :source_id => "A-source-a/match"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"},
        %{:kind => :match, :ref => "b#match", :source_id => "B-source-b#match"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.3", "US2.1"],
    :requirements => ["FR-002"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-E01-invalid_request",
    :operation => :catalog,
    :request => %{:league_code => "ZZ", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-invalid_request", :b => "F-E01-invalid_request"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-I01-invalid_request",
    :operation => :catalog,
    :request => %{:league_code => "ZZ", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-invalid_request", :b => "F-I01-invalid_request"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => nil
  },
  %{
    :id => "F-E01-unsupported_capability",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-unsupported_capability", :b => "F-E01-unsupported_capability"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-I01-unsupported_capability",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-unsupported_capability", :b => "F-I01-unsupported_capability"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E01-not_found",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-not_found", :b => "F-E01-not_found"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-I01-not_found",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-not_found", :b => "F-I01-not_found"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E01-authentication_failed",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-authentication_failed", :b => "F-E01-authentication_failed"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-I01-authentication_failed",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-authentication_failed", :b => "F-I01-authentication_failed"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E01-rate_limited",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-rate_limited", :b => "F-E01-rate_limited"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-I01-rate_limited",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-rate_limited", :b => "F-I01-rate_limited"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E01-unavailable",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-unavailable", :b => "F-E01-unavailable"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-I01-unavailable",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-unavailable", :b => "F-I01-unavailable"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E01-timeout",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-timeout", :b => "F-E01-timeout"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-I01-timeout",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-timeout", :b => "F-I01-timeout"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E01-invalid_response",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E01-invalid_response", :b => "F-E01-invalid_response"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-011"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-I01-invalid_response",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-I01-invalid_response", :b => "F-I01-invalid_response"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.5"],
    :requirements => ["FR-011", "FR-013"],
    :success_criteria => ["SC-002", "SC-006"],
    :state_oracle => "exact five-table/read equality",
    :state_check => "catalog-isolation",
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E02-known-delay",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E02-known-delay", :b => "F-E02-known-delay"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E02-unknown-delay",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E02-unknown-delay", :b => "F-E02-unknown-delay"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E02-bad-delay",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E02-bad-delay", :b => "F-E02-bad-delay"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-url",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-url", :b => "F-E03-url"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-userinfo",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-userinfo", :b => "F-E03-userinfo"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-token-query",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-token-query", :b => "F-E03-token-query"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-header",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-header", :b => "F-E03-header"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-source-ref",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-source-ref", :b => "F-E03-source-ref"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-source-id",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-source-id", :b => "F-E03-source-id"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-fixture-id",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-fixture-id", :b => "F-E03-fixture-id"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-exception",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-exception", :b => "F-E03-exception"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-E03-unknown-key",
    :operation => :catalog,
    :request => %{
      :league_code => "PL",
      :start_year => 2025,
      :end_year => 2026,
      "FAKE_SENTINEL" => "bad"
    },
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-unknown-key", :b => "F-E03-unknown-key"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => nil
  },
  %{
    :id => "F-E03-provider-label",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-E03-provider-label", :b => "F-E03-provider-label"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.1"],
    :requirements => ["FR-009", "FR-012"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D01-default-before",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D01-default-before", :b => "F-D01-default-before"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3"],
    :requirements => ["FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D01-default-at",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D01-default-at", :b => "F-D01-default-at"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3"],
    :requirements => ["FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D01-default-after",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D01-default-after", :b => "F-D01-default-after"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3"],
    :requirements => ["FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D01-default-never",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D01-default-never", :b => "F-D01-default-never"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3"],
    :requirements => ["FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D02-custom-before",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D02-custom-before", :b => "F-D02-custom-before"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3"],
    :requirements => ["FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D02-custom-at",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D02-custom-at", :b => "F-D02-custom-at"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3"],
    :requirements => ["FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D02-custom-after",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D02-custom-after", :b => "F-D02-custom-after"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3"],
    :requirements => ["FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D02-custom-validation-delay",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D02-custom-validation-delay", :b => "F-D02-custom-validation-delay"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 1,
    :scenarios => ["US3.3"],
    :requirements => ["FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D02-custom-error-at-boundary",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D02-custom-error-at-boundary", :b => "F-D02-custom-error-at-boundary"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.3"],
    :requirements => ["FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D03-pages-complete",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D03-pages-complete", :b => "F-D03-pages-complete"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.4"],
    :requirements => ["FR-003", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D04-later-page-error",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D04-later-page-error", :b => "F-D04-later-page-error"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.4"],
    :requirements => ["FR-003", "FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D04-later-page-timeout",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D04-later-page-timeout", :b => "F-D04-later-page-timeout"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.4"],
    :requirements => ["FR-003", "FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D04-cumulative-page-delay",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026, :timeout_ms => 7},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D04-cumulative-page-delay", :b => "F-D04-cumulative-page-delay"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.4"],
    :requirements => ["FR-003", "FR-009", "FR-010"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D05-late-result",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D05-late-result", :b => "F-D05-late-result"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3", "US3.4"],
    :requirements => ["FR-010", "FR-011"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D05-next-call",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D05-next-call", :b => "F-D05-next-call"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3", "US3.4"],
    :requirements => ["FR-010", "FR-011"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D05-caller-exit",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D05-caller-exit", :b => "F-D05-caller-exit"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3", "US3.4"],
    :requirements => ["FR-010", "FR-011"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-D05-crash",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-D05-crash", :b => "F-D05-crash"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US3.2", "US3.3", "US3.4"],
    :requirements => ["FR-010", "FR-011"],
    :success_criteria => ["SC-003"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-O01-repeat",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-O01-repeat", :b => "F-O01-repeat"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US4.1", "US4.2", "US4.3"],
    :requirements => ["FR-013"],
    :success_criteria => ["SC-004"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-O02-bijection-negative",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-O02-bijection-negative", :b => "F-O02-bijection-negative"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US4.1", "US4.2", "US4.3"],
    :requirements => ["FR-005", "FR-013"],
    :success_criteria => ["SC-004"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-O03-traceability",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2025, :end_year => 2026},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-O03-traceability", :b => "F-O03-traceability"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "A-source-a/league"},
        %{:kind => :season, :ref => "a/season", :source_id => "A-source-a/season"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "B-source-b#league"},
        %{:kind => :season, :ref => "b#season", :source_id => "B-source-b#season"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US4.1", "US4.2", "US4.3"],
    :requirements => ["FR-013"],
    :success_criteria => ["SC-004"],
    :expected_scope => %{:league_code => "PL", :start_year => 2025, :end_year => 2026}
  },
  %{
    :id => "F-C05-same-id-other-scope-2024",
    :operation => :catalog,
    :request => %{:league_code => "PL", :start_year => 2024, :end_year => 2025},
    :positions => %{"FW" => "Forward", "GK" => "Goalkeeper"},
    :sources => %{:a => "F-C05-same-id-other-scope-2024", :b => "F-C05-same-id-other-scope-2024"},
    :correspondence => %{
      :a => %{
        :league => %{"a/league" => "league"},
        :season => %{"a/season" => "season"},
        :team => %{"a/red" => "red", "a/blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"a/first" => "first", "a/second" => "second"},
        :match => %{},
        :performance => %{}
      },
      :b => %{
        :league => %{"b#league" => "league"},
        :season => %{"b#season" => "season"},
        :team => %{"b#red" => "red", "b#blue" => "blue"},
        :position => %{"FW" => "FW", "GK" => "GK"},
        :player => %{"b#first" => "first", "b#second" => "second"},
        :match => %{},
        :performance => %{}
      }
    },
    :expected_bindings => %{
      :a => [
        %{:kind => :league, :ref => "a/league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "a/season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "a/red", :source_id => "A-source-a/red"},
        %{:kind => :team, :ref => "a/blue", :source_id => "A-source-a/blue"},
        %{:kind => :player, :ref => "a/first", :source_id => "A-source-a/first"},
        %{:kind => :player, :ref => "a/second", :source_id => "A-source-a/second"}
      ],
      :b => [
        %{:kind => :league, :ref => "b#league", :source_id => "shared-public-id"},
        %{:kind => :season, :ref => "b#season", :source_id => "shared-public-id"},
        %{:kind => :team, :ref => "b#red", :source_id => "B-source-b#red"},
        %{:kind => :team, :ref => "b#blue", :source_id => "B-source-b#blue"},
        %{:kind => :player, :ref => "b#first", :source_id => "B-source-b#first"},
        %{:kind => :player, :ref => "b#second", :source_id => "B-source-b#second"}
      ]
    },
    :validation_us => 0,
    :scenarios => ["US1.1", "US4.2"],
    :requirements => ["FR-005"],
    :success_criteria => ["SC-002", "SC-005"],
    :expected_scope => %{:league_code => "PL", :start_year => 2024, :end_year => 2025}
  }
]
