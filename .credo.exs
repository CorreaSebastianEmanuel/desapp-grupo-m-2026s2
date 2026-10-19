%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "lib/",
          "config/",
          "priv/",
          "scripts/",
          "test/",
          "*.ex",
          "*.exs",
          ".credo.exs",
          ".formatter.exs"
        ],
        excluded: []
      },
      strict: false,
      color: false
    }
  ]
}
