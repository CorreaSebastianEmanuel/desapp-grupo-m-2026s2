defmodule FootballMarket.Repo.Migrations.AlignStatisticsIdentityWhitespace do
  use Ecto.Migration

  def up do
    # Unicode White_Space, matching String.trim/1 in the pinned Elixir toolchain.
    # Keep this explicit: PostgreSQL's locale-dependent [:space:] excludes NBSP.
    execute(~S"""
    CREATE FUNCTION statistics_trim_identity(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT PARALLEL SAFE AS $$
      SELECT btrim($1, U&'\0009\000A\000B\000C\000D\0020\0085\00A0\1680\2000\2001\2002\2003\2004\2005\2006\2007\2008\2009\200A\2028\2029\202F\205F\3000')
    $$
    """)

    # PostgreSQL 17 recomputes only the generated key. The existing unique and
    # nonblank constraints abort this transaction if old facts would conflict;
    # never repair those facts implicitly or disable append-only protections.
    execute("""
    ALTER TABLE matches ALTER COLUMN normalized_identity
    SET EXPRESSION AS (lower(statistics_trim_identity(match_identity)))
    """)

    execute("ANALYZE matches")
  end

  def down do
    execute("""
    ALTER TABLE matches ALTER COLUMN normalized_identity
    SET EXPRESSION AS (lower(regexp_replace(match_identity, '^[[:space:]]+|[[:space:]]+$', '', 'g')))
    """)

    execute("DROP FUNCTION statistics_trim_identity(text)")
  end
end
