#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DEPLOY="$(mktemp)"
trap 'rm -f "$TMP_DEPLOY"' EXIT

sed '/^main "\$@"$/d' "$ROOT_DIR/deploy.sh" > "$TMP_DEPLOY"
source "$TMP_DEPLOY"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL %s: expected <%s>, got <%s>\n' "$label" "$expected" "$actual" >&2
    exit 1
  fi
}

mysql_dsn='newapi:secret@tcp(127.0.0.1:3306)/new-api?charset=utf8mb4&parseTime=True'

assert_eq "mysql" "$(extract_dsn_engine "$mysql_dsn")" "mysql engine"
assert_eq "127.0.0.1" "$(extract_dsn_host "$mysql_dsn")" "mysql host"
assert_eq "newapi" "$(extract_dsn_user "$mysql_dsn")" "mysql user"
assert_eq "secret" "$(extract_dsn_password "$mysql_dsn")" "mysql password"
assert_eq "3306" "$(extract_dsn_port "$mysql_dsn")" "mysql port"
assert_eq "new-api" "$(extract_dsn_dbname "$mysql_dsn")" "mysql database"

echo "deploy DSN parsing tests passed"
