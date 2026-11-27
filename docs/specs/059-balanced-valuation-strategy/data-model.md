# Balanced in-memory model

Reuse shared structs/relationships from the [valuation contract](../058-valuation-contract-normalization/contracts/valuation-context.md). No schema, migration, persistent entity or mutable state.

| Value | Fields / relationships | Validation / ownership |
|---|---|---|
| Balanced Definition | Existing Definition: module FootballMarket.Valuation.Balanced, strategy_id balanced, version 1, config weights | Explicit original reviewed module/config; inherited identity/version binding, no active lookup |
| Config | Plain nonempty weights map; counting-metric atom → integer/valid finite Decimal | Exactly one config key, unrestricted signed values including zero; no floats/strings/booleans/nonfinite fields/role maps/defaults |
| Derived requirements | overall → ordered metric list | Exactly keys present in weights, including zero; must equal request requirements |
| Request rules | Existing player/season/week/historical mapping/references | Half-open UTC Monday week; references exactly configured keys, strictly positive exact numbers; shared validation unchanged |
| Rounded features | Existing FeatureView.features.overall; configured Decimal features at exponent -6 | Every accepted selected row contributes; unknown required fails; no raw-fact exposure |
| Contribution | Ephemeral signed coefficient/base-10 exponent of feature × weight | Exact integer operations, early zero elimination, canonical exponents/cancellation; never persisted/public |
| Result / Descriptor | Existing Prepared, signed six-place score and reproduction descriptor | Original facts/membership/request/config/requirements/features/score bound by existing Evidence/Replay; no executable module serialized |

Allowed keys/order: goals, assists, shots_on_target, tackles, interceptions, saves, goals_conceded, yellow_cards, red_cards, as atoms. Omission removes a requirement; zero does not. Engine canonicalizes equivalent Decimal representations; integer and Decimal encoding retain existing type tags.

Flow: explicit rules → common validation/local selection → authenticated Prepared → rounded FeatureView → exact Balanced sum → common final rounding → ScoreResult/Descriptor. Replay resolves original facts/rules/membership. Fresh evaluation after changed config or late arrival creates a separate result. No transition mutates earlier results, facts, quotes or finances. Ordinary failures return existing Error without score; infrastructure failures remain visible.
