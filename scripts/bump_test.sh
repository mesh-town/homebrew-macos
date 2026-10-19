#!/usr/bin/env bash
# Tests for bump.sh on a temporary copy of the formula. No network access.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bump="$here/bump.sh"
orig="$here/../Formula/meshtown.rb"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

export BUMP_FORMULA="$work/meshtown.rb"
fails=0
total=0

pass() { total=$((total + 1)); echo "ok - $1"; }
fail() { total=$((total + 1)); fails=$((fails + 1)); echo "not ok - $1"; }

reset() { cp "$orig" "$BUMP_FORMULA"; cp "$orig" "$work/pristine.rb"; }
unchanged() { cmp -s "$BUMP_FORMULA" "$work/pristine.rb"; }

SHA_A="$(printf 'a%.0s' $(seq 1 64))"
SHA_B="ABCDEF0123456789abcdef0123456789ABCDEF0123456789abcdef0123456789"
SHA_B_LOW="$(printf '%s' "$SHA_B" | tr 'A-F' 'a-f')"
SHA_C="$(printf 'c%.0s' $(seq 1 64))"
SHA_D="FEDCBA9876543210fedcba9876543210FEDCBA9876543210fedcba9876543210"
SHA_D_LOW="$(printf '%s' "$SHA_D" | tr 'A-F' 'a-f')"
APP="MeshTown-macos-arm64-1.2.3.zip"
CLI="meshtown-cli-1.2.3-aarch64-apple-darwin.tar.gz"

sums_ok="$work/sums_ok"
printf '%s  MeshTown-macos-x86_64-1.2.3.zip\n%s  %s\n%s  %s\n' "$SHA_A" "$SHA_B" "$APP" "$SHA_D" "$CLI" > "$sums_ok"
sums_star="$work/sums_star"
printf '%s *%s\n%s *%s\n' "$SHA_A" "$APP" "$SHA_C" "$CLI" > "$sums_star"

# expect_fail <name> <args...>: bump must exit non-zero, print to stderr, leave the formula untouched.
expect_fail() {
  local name="$1"
  shift
  reset
  if "$bump" "$@" > "$work/out" 2> "$work/err"; then
    fail "$name (exit 0)"
  elif [ ! -s "$work/err" ]; then
    fail "$name (empty stderr)"
  elif ! unchanged; then
    fail "$name (formula changed)"
  else
    pass "$name"
  fi
}

# happy path
reset
if "$bump" 1.2.3 --sums "$sums_ok" > /dev/null 2>&1; then
  want='  url "https://github.com/mesh-town/meshtown/releases/download/v1.2.3/MeshTown-macos-arm64-1.2.3.zip"'
  [ "$(grep '^  url ' "$BUMP_FORMULA")" = "$want" ] && pass "version updated inside url" || fail "version updated inside url"
  want='    url "https://github.com/mesh-town/meshtown/releases/download/v1.2.3/meshtown-cli-1.2.3-aarch64-apple-darwin.tar.gz"'
  [ "$(grep '^    url ' "$BUMP_FORMULA")" = "$want" ] && pass "cli resource url updated" || fail "cli resource url updated"
  grep -qF "    sha256 \"$SHA_D_LOW\"" "$BUMP_FORMULA" && pass "cli sha256 updated, lowercased" || fail "cli sha256 updated, lowercased"
  grep -q '^  version ' "$BUMP_FORMULA" && fail "no separate version line" || pass "no separate version line"
  grep -qF "  sha256 \"$SHA_B_LOW\"" "$BUMP_FORMULA" && pass "sha256 updated, lowercased" || fail "sha256 updated, lowercased"
  grep -q 'placeholder hash' "$BUMP_FORMULA" && fail "placeholder comment removed" || pass "placeholder comment removed"
  ruby -c "$BUMP_FORMULA" > /dev/null 2>&1 && pass "ruby -c after bump" || fail "ruby -c after bump"
else
  fail "happy path (bump failed)"
fi

# idempotence
cp "$BUMP_FORMULA" "$work/after1.rb"
if "$bump" 1.2.3 --sums "$sums_ok" > /dev/null 2>&1 && cmp -s "$BUMP_FORMULA" "$work/after1.rb"; then
  pass "idempotent"
else
  fail "idempotent"
fi

# flags in any order, "*name" form
reset
"$bump" 1.2.3 --sums "$sums_star" > /dev/null 2>&1 && grep -qF "  sha256 \"$SHA_A\"" "$BUMP_FORMULA" && grep -qF "    sha256 \"$SHA_C\"" "$BUMP_FORMULA" && pass "sums with '*name' form" || fail "sums with '*name' form"

# file:// sums
reset
"$bump" 1.2.3 --sums "file://$sums_ok" > /dev/null 2>&1 && grep -qF "sha256 \"$SHA_B_LOW\"" "$BUMP_FORMULA" && pass "--sums file://" || fail "--sums file://"

# --base-url, flags in the other order
reset
if "$bump" 1.2.3 --base-url "http://127.0.0.1:8000/dl/" --sums "$sums_ok" > /dev/null 2>&1; then
  want='  url "http://127.0.0.1:8000/dl/MeshTown-macos-arm64-1.2.3.zip"'
  [ "$(grep '^  url ' "$BUMP_FORMULA")" = "$want" ] && pass "--base-url replaces url" || fail "--base-url replaces url"
  want='    url "http://127.0.0.1:8000/dl/meshtown-cli-1.2.3-aarch64-apple-darwin.tar.gz"'
  [ "$(grep '^    url ' "$BUMP_FORMULA")" = "$want" ] && pass "--base-url replaces cli url" || fail "--base-url replaces cli url"
  ruby -c "$BUMP_FORMULA" > /dev/null 2>&1 && pass "ruby -c after --base-url" || fail "ruby -c after --base-url"
else
  fail "--base-url (bump failed)"
fi

# failures
expect_fail "no arguments"
expect_fail "bad version 1.2" 1.2 --sums "$sums_ok"
expect_fail "bad version v1.2.3" v1.2.3 --sums "$sums_ok"
expect_fail "bad version 1.2.3.4" 1.2.3.4 --sums "$sums_ok"
expect_fail "bad version 1.2.x" 1.2.x --sums "$sums_ok"
expect_fail "unknown argument" 1.2.3 --bogus --sums "$sums_ok"
expect_fail "--sums without value" 1.2.3 --sums
expect_fail "--base-url without value" 1.2.3 --sums "$sums_ok" --base-url
expect_fail "missing sums file" 1.2.3 --sums "$work/nonexistent"
expect_fail "missing file:// sums" 1.2.3 --sums "file://$work/nonexistent"
expect_fail "no archive line (other version)" 9.9.9 --sums "$sums_ok"

printf 'garbage line\n' > "$work/sums_empty"
expect_fail "no archive line (garbage)" 1.2.3 --sums "$work/sums_empty"

printf '%s  %s\n%s  %s\n' "abc123" "$APP" "$SHA_C" "$CLI" > "$work/sums_short"
expect_fail "sha not 64 hex" 1.2.3 --sums "$work/sums_short"

printf '%s  %s\n%s  %s\n' "$(printf 'g%.0s' $(seq 1 64))" "$APP" "$SHA_C" "$CLI" > "$work/sums_nonhex"
expect_fail "sha 64 chars but not hex" 1.2.3 --sums "$work/sums_nonhex"

printf '%s  %s\n%s  %s\n%s  %s\n' "$SHA_A" "$APP" "$SHA_B" "$APP" "$SHA_C" "$CLI" > "$work/sums_dup"
expect_fail "duplicate archive line" 1.2.3 --sums "$work/sums_dup"

printf '%s  %s\n' "$SHA_A" "$APP" > "$work/sums_nocli"
expect_fail "no cli entry" 1.2.3 --sums "$work/sums_nocli"

printf '%s  %s\n%s  %s\n%s  %s\n' "$SHA_A" "$APP" "$SHA_B" "$CLI" "$SHA_C" "$CLI" > "$work/sums_dupcli"
expect_fail "duplicate cli entry" 1.2.3 --sums "$work/sums_dupcli"

printf '%s  %s\n%s  %s\n' "$SHA_A" "$APP" "xyz" "$CLI" > "$work/sums_badcli"
expect_fail "bad cli sha256" 1.2.3 --sums "$work/sums_badcli"

printf '%s  %s\n' "$SHA_C" "$CLI" > "$work/sums_noapp"
expect_fail "no app entry" 1.2.3 --sums "$work/sums_noapp"

echo "# $((total - fails))/$total passed"
[ "$fails" -eq 0 ]
