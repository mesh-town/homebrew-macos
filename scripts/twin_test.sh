#!/usr/bin/env bash
# Tests for twin.sh on temporary copies of the formula. No network access.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
twin="$here/twin.sh"
orig="$here/../Formula/meshtown.rb"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fails=0
total=0
pass() { total=$((total + 1)); echo "ok - $1"; }
fail() { total=$((total + 1)); fails=$((fails + 1)); echo "not ok - $1"; }
check() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }

main="$work/meshtown.rb"
out="$work/mesh-town.rb"
cp "$orig" "$main"

check "writes the twin next to the formula" '"$twin" "$main" > /dev/null && [ -f "$out" ]'
check "class name is MeshTown" 'grep -q "^class MeshTown < Formula$" "$out"'
check "no Meshtown class left" '! grep -q "^class Meshtown " "$out"'
check "twin conflicts with meshtown" 'grep -q "^  conflicts_with \"mesh-town/macos/meshtown\", " "$out"'
check "twin does not conflict with itself" '! grep -q "mesh-town/macos/mesh-town\"" "$out"'
check "only the header, class and conflicts lines differ" \
  '[ "$(diff "$main" "$out" | grep -c "^>")" = 3 ] && [ "$(diff "$main" "$out" | grep -c "^<")" = 2 ]'
check "ruby -c on the twin" 'ruby -c "$out" > /dev/null 2>&1'
check "--check passes when in sync" '"$twin" --check "$main"'
check "the repository twin is in sync" '"$twin" --check "$orig"'

sed -i.bak 's/0\.3\./9.9./' "$main"
check "--check fails when the formula changed" '! "$twin" --check "$main" 2> /dev/null'
check "--check does not write the twin" '! grep -q "9\.9\." "$out"'
check "a rerun picks up the change" '"$twin" "$main" > /dev/null && "$twin" --check "$main"'

rm "$out"
check "--check fails when the twin is missing" '! "$twin" --check "$main" 2> /dev/null'

grep -v '^  conflicts_with ' "$orig" > "$main"
check "fails without the conflicts_with line" '! "$twin" "$main" 2> /dev/null && [ ! -f "$out" ]'

sed 's/^class Meshtown /class Other /' "$orig" > "$main"
check "fails without the Meshtown class" '! "$twin" "$main" 2> /dev/null && [ ! -f "$out" ]'

check "fails on a missing formula" '! "$twin" "$work/none.rb" 2> /dev/null'
check "fails on extra arguments" '! "$twin" "$main" "$main" 2> /dev/null'

echo "# $((total - fails))/$total passed"
[ "$fails" -eq 0 ]
