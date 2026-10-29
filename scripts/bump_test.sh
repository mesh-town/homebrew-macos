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
APP_X="MeshTown-macos-x86_64-1.2.3.zip"
CLI_X="meshtown-cli-1.2.3-x86_64-apple-darwin.tar.gz"
SHA_E="$(printf 'e%.0s' $(seq 1 64))"
SHA_F="$(printf 'f%.0s' $(seq 1 64))"

sums_ok="$work/sums_ok"
printf '%s  %s\n%s  %s\n%s  %s\n%s  %s\n' "$SHA_A" "$APP_X" "$SHA_B" "$APP" "$SHA_D" "$CLI" "$SHA_E" "$CLI_X" > "$sums_ok"
sums_star="$work/sums_star"
printf '%s *%s\n%s *%s\n%s *%s\n%s *%s\n' "$SHA_A" "$APP" "$SHA_C" "$CLI" "$SHA_E" "$APP_X" "$SHA_F" "$CLI_X" > "$sums_star"

# sha_of <archive>: the sha256 value on the line right after the url that names the archive.
sha_of() { grep -A1 -F "/$1\"" "$BUMP_FORMULA" | tail -n 1 | sed 's/.*"\(.*\)"/\1/'; }
# url_of <archive>: the full url line naming the archive, indentation included.
url_of() { grep -F "/$1\"" "$BUMP_FORMULA"; }

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
  base="https://github.com/mesh-town/meshtown-dist/releases/download/v1.2.3"
  [ "$(url_of "$APP")" = "      url \"$base/$APP\"" ] && pass "arm64 app url updated" || fail "arm64 app url updated"
  [ "$(url_of "$CLI")" = "      url \"$base/$CLI\"" ] && pass "arm64 cli url updated" || fail "arm64 cli url updated"
  [ "$(url_of "$APP_X")" = "      url \"$base/$APP_X\"" ] && pass "intel app url updated" || fail "intel app url updated"
  [ "$(url_of "$CLI_X")" = "      url \"$base/$CLI_X\"" ] && pass "intel cli url updated" || fail "intel cli url updated"
  [ "$(sha_of "$APP")" = "$SHA_B_LOW" ] && pass "arm64 app sha256, lowercased" || fail "arm64 app sha256, lowercased"
  [ "$(sha_of "$CLI")" = "$SHA_D_LOW" ] && pass "arm64 cli sha256, lowercased" || fail "arm64 cli sha256, lowercased"
  [ "$(sha_of "$APP_X")" = "$SHA_A" ] && pass "intel app sha256" || fail "intel app sha256"
  [ "$(sha_of "$CLI_X")" = "$SHA_E" ] && pass "intel cli sha256" || fail "intel cli sha256"
  [ "$(url_of SHA256SUMS)" = "  url \"$base/SHA256SUMS\"" ] && pass "sums url updated" || fail "sums url updated"
  [ "$(sha_of SHA256SUMS)" = "$(shasum -a 256 "$sums_ok" | awk '{ print $1 }')" ] && pass "sums file sha256" || fail "sums file sha256"
  [ "$(grep -c 'sha256 "' "$BUMP_FORMULA")" = 5 ] && pass "five sha256 lines" || fail "five sha256 lines"
  grep -q '^  version ' "$BUMP_FORMULA" && fail "no separate version line" || pass "no separate version line"
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

# "*name" form
reset
if "$bump" 1.2.3 --sums "$sums_star" > /dev/null 2>&1 && [ "$(sha_of "$APP")" = "$SHA_A" ] && [ "$(sha_of "$CLI")" = "$SHA_C" ] && [ "$(sha_of "$APP_X")" = "$SHA_E" ] && [ "$(sha_of "$CLI_X")" = "$SHA_F" ]; then
  pass "sums with '*name' form"
else
  fail "sums with '*name' form"
fi

# file:// sums
reset
"$bump" 1.2.3 --sums "file://$sums_ok" > /dev/null 2>&1 && [ "$(sha_of "$APP")" = "$SHA_B_LOW" ] && pass "--sums file://" || fail "--sums file://"

# --base-url, flags in the other order
reset
if "$bump" 1.2.3 --base-url "http://127.0.0.1:8000/dl/" --sums "$sums_ok" > /dev/null 2>&1; then
  dl="http://127.0.0.1:8000/dl"
  [ "$(url_of "$APP")" = "      url \"$dl/$APP\"" ] && pass "--base-url replaces app url" || fail "--base-url replaces app url"
  [ "$(url_of "$CLI_X")" = "      url \"$dl/$CLI_X\"" ] && pass "--base-url replaces intel cli url" || fail "--base-url replaces intel cli url"
  [ "$(grep -c "\"$dl/" "$BUMP_FORMULA")" = 5 ] && pass "--base-url replaces all five urls" || fail "--base-url replaces all five urls"
  ruby -c "$BUMP_FORMULA" > /dev/null 2>&1 && pass "ruby -c after --base-url" || fail "ruby -c after --base-url"
else
  fail "--base-url (bump failed)"
fi

# a formula that still has the old host moves to the distribution repository
reset
sed "s#mesh-town/meshtown-dist/releases#mesh-town/meshtown/releases#" "$orig" > "$BUMP_FORMULA"
if grep -q 'mesh-town/meshtown/releases' "$BUMP_FORMULA" && "$bump" 1.2.3 --sums "$sums_ok" > /dev/null 2>&1; then
  grep -q 'mesh-town/meshtown/releases' "$BUMP_FORMULA" && fail "formula with the old host moves to dist" || pass "formula with the old host moves to dist"
else
  fail "formula with the old host moves to dist (setup or bump failed)"
fi

# default sums url is the distribution repository: a curl stub records the requested url
reset
mkdir "$work/stub"
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*" > "%s/curl_args"\nout=""\nwhile [ "$#" -gt 0 ]; do [ "$1" = -o ] && out="$2"; shift; done\ncp "%s" "$out"\n' "$work" "$sums_ok" > "$work/stub/curl"
chmod +x "$work/stub/curl"
if PATH="$work/stub:$PATH" "$bump" 1.2.3 > /dev/null 2>&1 && grep -q 'https://github.com/mesh-town/meshtown-dist/releases/download/v1.2.3/SHA256SUMS' "$work/curl_args"; then
  pass "default sums url is dist"
else
  fail "default sums url is dist"
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

# sums_with <file> <arm app sha> <arm cli sha> <intel app sha> <intel cli sha>: a complete sums file.
sums_with() { printf '%s  %s\n%s  %s\n%s  %s\n%s  %s\n' "$2" "$APP" "$3" "$CLI" "$4" "$APP_X" "$5" "$CLI_X" > "$1"; }

sums_with "$work/sums_short" "abc123" "$SHA_C" "$SHA_A" "$SHA_E"
expect_fail "sha not 64 hex" 1.2.3 --sums "$work/sums_short"

sums_with "$work/sums_nonhex" "$(printf 'g%.0s' $(seq 1 64))" "$SHA_C" "$SHA_A" "$SHA_E"
expect_fail "sha 64 chars but not hex" 1.2.3 --sums "$work/sums_nonhex"

sums_with "$work/sums_dup" "$SHA_A" "$SHA_C" "$SHA_A" "$SHA_E"
printf '%s  %s\n' "$SHA_B" "$APP" >> "$work/sums_dup"
expect_fail "duplicate archive line" 1.2.3 --sums "$work/sums_dup"

sums_with "$work/sums_dupcli" "$SHA_A" "$SHA_C" "$SHA_A" "$SHA_E"
printf '%s  %s\n' "$SHA_B" "$CLI" >> "$work/sums_dupcli"
expect_fail "duplicate cli entry" 1.2.3 --sums "$work/sums_dupcli"

sums_with "$work/sums_badcli" "$SHA_A" "xyz" "$SHA_A" "$SHA_E"
expect_fail "bad cli sha256" 1.2.3 --sums "$work/sums_badcli"

printf '%s  %s\n%s  %s\n%s  %s\n' "$SHA_C" "$CLI" "$SHA_A" "$APP_X" "$SHA_E" "$CLI_X" > "$work/sums_noapp"
expect_fail "no app entry" 1.2.3 --sums "$work/sums_noapp"

printf '%s  %s\n' "$SHA_A" "$APP" > "$work/sums_nocli"
expect_fail "no cli entry" 1.2.3 --sums "$work/sums_nocli"

# Intel archives missing: the arm64 entries alone must not be enough.
printf '%s  %s\n%s  %s\n' "$SHA_A" "$APP" "$SHA_C" "$CLI" > "$work/sums_nointel"
expect_fail "no intel entries" 1.2.3 --sums "$work/sums_nointel"

printf '%s  %s\n%s  %s\n%s  %s\n' "$SHA_A" "$APP" "$SHA_C" "$CLI" "$SHA_E" "$CLI_X" > "$work/sums_nointelapp"
expect_fail "no intel app entry" 1.2.3 --sums "$work/sums_nointelapp"

printf '%s  %s\n%s  %s\n%s  %s\n' "$SHA_A" "$APP" "$SHA_C" "$CLI" "$SHA_E" "$APP_X" > "$work/sums_nointelcli"
expect_fail "no intel cli entry" 1.2.3 --sums "$work/sums_nointelcli"

echo "# $((total - fails))/$total passed"
[ "$fails" -eq 0 ]
