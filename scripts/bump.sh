#!/usr/bin/env bash
# Update the version (inside both urls) and both sha256 values (app zip and cli archive) in Formula/meshtown.rb from a release's SHA256SUMS.
set -euo pipefail

usage() {
  echo "Usage: bump.sh <X.Y.Z> [--sums <file|URL>] [--base-url <URL>]" >&2
  exit 2
}
die() {
  echo "bump.sh: $*" >&2
  exit 1
}

[ "$#" -ge 1 ] || usage
version="$1"
shift
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "bad version '$version' (want X.Y.Z)"

sums=""
base_url=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sums)
      [ "$#" -ge 2 ] || usage
      sums="$2"
      shift 2
      ;;
    --base-url)
      [ "$#" -ge 2 ] || usage
      base_url="${2%/}"
      [ -n "$base_url" ] || usage
      shift 2
      ;;
    *) usage ;;
  esac
done

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
formula="${BUMP_FORMULA:-$here/../Formula/meshtown.rb}"
[ -f "$formula" ] || die "formula not found: $formula"

[ -n "$sums" ] || sums="https://github.com/mesh-town/meshtown/releases/download/v${version}/SHA256SUMS"

case "$sums" in
  http://* | https://* | file://*)
    content="$(curl -fsSL "$sums")" || die "cannot download $sums"
    ;;
  *)
    [ -f "$sums" ] || die "sums file not found: $sums"
    content="$(cat "$sums")"
    ;;
esac

# lookup_sha <archive>: print the lowercase sha256 of the single entry for the archive, or exit with an error.
lookup_sha() {
  local archive="$1" matches
  matches="$(printf '%s\n' "$content" | awk -v n="$archive" '
    { sub(/\r$/, "") }
    NF == 2 && ($2 == n || $2 == "*" n) { print $1 }')"
  [ -n "$matches" ] || die "no entry for $archive in sums"
  [ "$(printf '%s\n' "$matches" | wc -l | tr -d ' ')" -eq 1 ] || die "duplicate entries for $archive in sums"
  [[ "$matches" =~ ^[0-9a-fA-F]{64}$ ]] || die "bad sha256 for $archive: $matches"
  printf '%s' "$matches" | tr 'A-F' 'a-f'
}

app_archive="MeshTown-macos-arm64-${version}.zip"
cli_archive="meshtown-cli-${version}-aarch64-apple-darwin.tar.gz"
sha="$(lookup_sha "$app_archive")"
cli_sha="$(lookup_sha "$cli_archive")"

tmp="$(mktemp "$formula.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
awk -v ver="$version" -v sha="$sha" -v cli_sha="$cli_sha" -v base="$base_url" \
  -v app="$app_archive" -v cli="$cli_archive" '
  /^  # placeholder hash/ { next }
  /^  sha256 "/ { print "  sha256 \"" sha "\""; next }
  /^    sha256 "/ { print "    sha256 \"" cli_sha "\""; next }
  /^  url "/ && base != "" { print "  url \"" base "/" app "\""; next }
  /^    url "/ && base != "" { print "    url \"" base "/" cli "\""; next }
  /^ +url "/ {
    gsub(/\/v[0-9]+\.[0-9]+\.[0-9]+\//, "/v" ver "/")
    gsub(/arm64-[0-9]+\.[0-9]+\.[0-9]+\.zip/, "arm64-" ver ".zip")
    gsub(/cli-[0-9]+\.[0-9]+\.[0-9]+-aarch64/, "cli-" ver "-aarch64")
    print
    next
  }
  { print }
' "$formula" > "$tmp"
chmod --reference="$formula" "$tmp" 2>/dev/null || chmod 0644 "$tmp"
mv "$tmp" "$formula"
trap - EXIT
echo "bumped $(basename "$formula") to $version (app $sha, cli $cli_sha)"
