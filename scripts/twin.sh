#!/usr/bin/env bash
# Write Formula/mesh-town.rb, the same formula under the second spelling of the name, from Formula/meshtown.rb:
# only the class name and the name in conflicts_with differ, so both
#   brew install mesh-town/macos/meshtown
#   brew install mesh-town/macos/mesh-town
# install the same app. An alias in Aliases/ is not enough: Homebrew 7 refuses an alias from an untrusted tap.
# Usage: twin.sh [--check] [<path to meshtown.rb>]; the twin is written next to it.
# With --check, the twin is not written: exit 1 if it is missing or out of date.
set -euo pipefail

die() {
  echo "twin.sh: $*" >&2
  exit 1
}

check=0
if [ "${1:-}" = --check ]; then
  check=1
  shift
fi
[ "$#" -le 1 ] || die "usage: twin.sh [--check] [<path to meshtown.rb>]"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
main="${1:-$here/../Formula/meshtown.rb}"
[ -f "$main" ] || die "formula not found: $main"
twin="$(dirname "$main")/mesh-town.rb"

class_from='^class Meshtown < Formula$'
conflict_from='^  conflicts_with "mesh-town/macos/mesh-town", '
[ "$(grep -c "$class_from" "$main")" = 1 ] || die "expected one 'class Meshtown < Formula' line in $main"
[ "$(grep -c "$conflict_from" "$main")" = 1 ] || die "expected one conflicts_with mesh-town/macos/mesh-town line in $main"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
{
  echo "# Generated from meshtown.rb by scripts/twin.sh: edit meshtown.rb, then run the script."
  sed -e 's/^class Meshtown < Formula$/class MeshTown < Formula/' \
    -e 's#^  conflicts_with "mesh-town/macos/mesh-town", #  conflicts_with "mesh-town/macos/meshtown", #' "$main"
} > "$tmp"

if [ "$check" = 1 ]; then
  cmp -s "$tmp" "$twin" || die "$twin is out of date: run scripts/twin.sh"
  exit 0
fi
chmod 0644 "$tmp"
mv "$tmp" "$twin"
trap - EXIT
echo "wrote $(basename "$twin")"
