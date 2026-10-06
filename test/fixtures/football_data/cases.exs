# Each entry has an independent expected outcome and exact outbound count.
(((
    leagues =
      for league <- ~w(PL BL1 PD SA FL1),
          do: %{id: "FD-C01-#{league}", league: league, expected: :ok, calls: 8}

    collections =
      for {variant, {category, calls}} <- [
            empty_teams: {:ok, 3},
            empty_squad: {:ok, 4},
            missing_teams: {:invalid_response, 2},
            null_squad: {:invalid_response, 3}
          ],
          do: %{id: "FD-C02-#{variant}", variant: variant, expected: category, calls: calls}

    invalid =
      for variant <-
            ~w(duplicate_player duplicate_team missing_name blank_tla missing_position unknown_position staff_row bad_id stale_transfer missing_current_team wrong_person wrong_team wrong_competition rollover bad_dates truncated)a,
          do: %{
            id: "FD-C05-#{variant}",
            variant: variant,
            expected: :invalid_response,
            calls: :bounded
          }

    statuses =
      for {status, category} <- [
            {400, :invalid_response},
            {401, :authentication_failed},
            {403, :authentication_failed},
            {404, :not_found},
            {410, :not_found},
            {429, :rate_limited},
            {301, :unavailable},
            {302, :unavailable},
            {307, :unavailable},
            {500, :unavailable},
            {503, :unavailable},
            {201, :invalid_response}
          ],
          do: %{id: "FD-E04-#{status}", status: status, expected: category, calls: 1}

    leagues ++
      collections ++
      invalid ++
      statuses ++
      [
        %{id: "FD-C03-late-failure", variant: :late_failure, expected: :unavailable, calls: 5},
        %{id: "FD-C04-same-names-roles", expected: :ok, calls: 8},
        %{id: "FD-C05-calendar", variant: :calendar, expected: :ok, calls: 8},
        %{
          id: "FD-S01-disabled",
          config: %{enabled: false},
          expected: :unsupported_capability,
          calls: 0
        },
        %{
          id: "FD-S02-missing",
          config: %{token: nil},
          expected: :authentication_failed,
          calls: 0
        },
        %{
          id: "FD-S02-blank",
          config: %{token: "   "},
          expected: :authentication_failed,
          calls: 0
        },
        %{id: "FD-S03-clean", expected: :ok, calls: 8},
        %{
          id: "FD-S04-secret-name",
          variant: :secret_name,
          expected: :invalid_response,
          calls: :bounded
        },
        %{
          id: "FD-S04-unsafe-origin",
          config: %{base_url: "https://evil.example"},
          expected: :invalid_request,
          calls: 0
        },
        %{
          id: "FD-S05-invalid",
          request: %{league_code: "XX", start_year: 2026, end_year: 2027},
          expected: :invalid_request,
          calls: 0
        },
        %{
          id: "FD-E01-absent",
          request: %{league_code: "PL", start_year: 2024, end_year: 2025},
          expected: :not_found,
          calls: 1
        },
        %{
          id: "FD-E02-historical",
          request: %{league_code: "PL", start_year: 2025, end_year: 2026},
          expected: :unsupported_capability,
          calls: 1
        },
        %{
          id: "FD-E03-performance",
          operation: :performances,
          expected: :unsupported_capability,
          calls: 0
        },
        %{
          id: "FD-E04-transport",
          transport_error: :unavailable,
          expected: :unavailable,
          calls: 1
        },
        %{id: "FD-E04-json", variant: :bad_json, expected: :invalid_response, calls: 1},
        %{
          id: "FD-E05-positive",
          status: 429,
          headers: [{"Retry-After", "3"}],
          delay: 3000,
          expected: :rate_limited,
          calls: 1
        },
        %{id: "FD-E05-missing", status: 429, expected: :rate_limited, calls: 1},
        %{
          id: "FD-E05-duplicate",
          status: 429,
          headers: [{"retry-after", "3"}, {"Retry-After", "4"}],
          expected: :rate_limited,
          calls: 1
        },
        %{id: "FD-E06-complete", variant: :large, expected: :ok, calls: 523},
        %{id: "FD-E06-quota", variant: :quota, expected: :rate_limited, calls: 11},
        %{id: "FD-D01-before", elapsed_us: 4_999_999, expected: :ok, calls: 8},
        %{id: "FD-D01-at", elapsed_us: 5_000_000, expected: :timeout, calls: 1},
        %{id: "FD-D01-after", elapsed_us: 5_000_001, expected: :timeout, calls: 1},
        %{id: "FD-D02-custom", timeout: 20, elapsed_us: 20_000, expected: :timeout, calls: 1},
        %{id: "FD-I01-read-only", expected: :ok, calls: 8},
        %{id: "FD-O01-repeat", expected: :ok, calls: 8}
      ]
  ) ++
    [
      %{
        id: "FD-E05-reset",
        status: 429,
        headers: [{"X-RequestCounter-Reset", "4"}],
        delay: 4000,
        expected: :rate_limited,
        calls: 1
      },
      %{
        id: "FD-E05-date",
        status: 429,
        headers: [{"Retry-After", "Tue, 06 Oct 2026 12:00:04 GMT"}],
        delay: 4000,
        expected: :rate_limited,
        calls: 1
      },
      %{
        id: "FD-E05-expired",
        status: 429,
        headers: [{"Retry-After", "Tue, 06 Oct 2026 11:59:59 GMT"}],
        expected: :rate_limited,
        calls: 1
      },
      %{
        id: "FD-E05-fallback",
        status: 429,
        headers: [{"Retry-After", "bad"}, {"X-RequestCounter-Reset", "2"}],
        delay: 2000,
        expected: :rate_limited,
        calls: 1
      },
      %{
        id: "FD-E05-zero",
        status: 429,
        headers: [{"Retry-After", "0"}],
        expected: :rate_limited,
        calls: 1
      },
      %{
        id: "FD-E05-negative",
        status: 429,
        headers: [{"Retry-After", "-2"}],
        expected: :rate_limited,
        calls: 1
      },
      %{
        id: "FD-E05-float",
        status: 429,
        headers: [{"Retry-After", "2.5"}],
        expected: :rate_limited,
        calls: 1
      },
      %{
        id: "FD-E05-counter",
        status: 429,
        headers: [{"X-RequestsAvailable", "4"}],
        expected: :rate_limited,
        calls: 1
      },
      %{id: "FD-D01-huge", timeout: 4_294_968_000, expected: :ok, calls: 8},
      %{id: "FD-D01-very-huge", timeout: 10_000_000_000_000, expected: :ok, calls: 8},
      %{id: "FD-D01-validation-at", validation_us: 5_000_000, expected: :timeout, calls: 8},
      %{id: "FD-D01-error-at", status: 403, elapsed_us: 5_000_000, expected: :timeout, calls: 1},
      %{
        id: "FD-D01-error-before",
        status: 403,
        elapsed_us: 4_999_999,
        expected: :authentication_failed,
        calls: 1
      }
    ]) ++
   [
     %{id: "FD-C03-multi", variant: :multi, expected: :ok, calls: 9},
     %{id: "FD-C03-multi-late", variant: :multi_late, expected: :unavailable, calls: 8},
     %{
       id: "FD-C05-cross-duplicate",
       variant: :cross_duplicate,
       expected: :invalid_response,
       calls: 6
     },
     %{id: "FD-C05-null-current", variant: :null_current, expected: :invalid_response, calls: 4},
     %{id: "FD-C05-final-absent", variant: :final_absent, expected: :invalid_response, calls: 8},
     %{
       id: "FD-C05-discovery-duplicate",
       variant: :discovery_duplicate,
       expected: :invalid_response,
       calls: 1
     },
     %{id: "FD-C05-list-count", variant: :list_count, expected: :invalid_response, calls: 2},
     %{id: "FD-C05-list-season", variant: :list_season, expected: :invalid_response, calls: 2},
     %{
       id: "FD-C05-list-competition",
       variant: :list_competition,
       expected: :invalid_response,
       calls: 2
     },
     %{id: "FD-C05-team-name", variant: :team_name, expected: :invalid_response, calls: 3},
     %{
       id: "FD-C05-team-membership",
       variant: :team_membership,
       expected: :invalid_response,
       calls: 3
     },
     %{
       id: "FD-C05-person-membership",
       variant: :person_membership,
       expected: :invalid_response,
       calls: 4
     },
     %{id: "FD-C04-null-name", variant: :null_name, expected: :invalid_response, calls: 3},
     %{
       id: "FD-C04-null-position",
       variant: :null_position,
       expected: :invalid_response,
       calls: 3
     },
     %{
       id: "FD-C04-blank-position",
       variant: :blank_position,
       expected: :invalid_response,
       calls: 3
     },
     %{id: "FD-C04-zero-id", variant: :zero_id, expected: :invalid_response, calls: 3},
     %{id: "FD-C04-boolean-id", variant: :boolean_id, expected: :invalid_response, calls: 3},
     %{id: "FD-S04-secret-id", variant: :secret_id, expected: :invalid_response, calls: 3},
     %{
       id: "FD-E01-both-years",
       request: %{league_code: "PL", start_year: 2026, end_year: 2026},
       expected: :not_found,
       calls: 1
     },
     %{
       id: "FD-E05-duplicate-reset",
       status: 429,
       headers: [
         {"Retry-After", "3"},
         {"X-RequestCounter-Reset", "2"},
         {"x-requestcounter-reset", "4"}
       ],
       expected: :rate_limited,
       calls: 1
     },
     %{
       id: "FD-E05-plus",
       status: 429,
       headers: [{"Retry-After", "+2"}],
       expected: :rate_limited,
       calls: 1
     },
     %{
       id: "FD-E05-bad-date",
       status: 429,
       headers: [{"Retry-After", "garbage"}],
       expected: :rate_limited,
       calls: 1
     },
     %{
       id: "FD-D02-shared",
       variant: :multi,
       per_call_us: 1000,
       timeout: 5,
       expected: :timeout,
       calls: 5
     },
     %{id: "FD-D02-validation-before", validation_us: 4999, timeout: 5, expected: :ok, calls: 8},
     %{
       id: "FD-D02-validation-after",
       validation_us: 5001,
       timeout: 5,
       expected: :timeout,
       calls: 8
     }
   ]) ++ [%{id: "FD-S04-exception", raise_secret: true, expected: :unavailable, calls: 1}]
