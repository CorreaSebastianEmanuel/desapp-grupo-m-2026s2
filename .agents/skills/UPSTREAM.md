# Vendored skill sources

The following skills were installed with the repository-local destination using the Codex skill-installer helper:

- `.agents/skills/elixir-essentials/` from `igmarin/elixir-phoenix-skills/skills/elixir-essentials/`
- `.agents/skills/ecto-essentials/` from `igmarin/elixir-phoenix-skills/skills/ecto-essentials/`
- `.agents/skills/code-quality/` from `igmarin/elixir-phoenix-skills/skills/code-quality/`

All three were copied from upstream commit `f69eb69a7bd66f5d45921f1c220e35b87bf934b4` (resolved from `main`) and are distributed under the upstream MIT license in `LICENSE.elixir-phoenix-skills`.

Local adaptation: upstream `ecto-essentials/assets/changeset_snippets.ex` is retained as `changeset_snippets.ex.md`, wrapped in a Markdown Elixir code fence. It is reference documentation, not a maintained or compiled application source file; the upstream example content is unchanged.
