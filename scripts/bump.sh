#!/usr/bin/env bash
# Update the version in all urls and sha256 values of Formula/meshtown.rb from a release's SHA256SUMS:
# the SHA256SUMS file itself, then the app zip and the cli archive for arm64 and for Intel.
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

sums_file="$(mktemp)"
trap 'rm -f "$sums_file"' EXIT
case "$sums" in
  http://* | https://* | file://*)
    curl -fsSL "$sums" -o "$sums_file" || die "cannot download $sums"
    ;;
  *)
    [ -f "$sums" ] || die "sums file not found: $sums"
    cp "$sums" "$sums_file"
    ;;
esac
content="$(cat "$sums_file")"
sums_sha="$(shasum -a 256 "$sums_file" | awk '{ print $1 }')"

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

# The formula has the SHA256SUMS file as its url, then one app archive and one cli archive
# per architecture; each sha256 line belongs to the url line right above it.
pairs="SHA256SUMS ${sums_sha}"$'\n'
for arch in arm64 x86_64; do
  cli_arch=aarch64
  if [ "$arch" = x86_64 ]; then cli_arch=x86_64; fi
  for archive in "MeshTown-macos-${arch}-${version}.zip" "meshtown-cli-${version}-${cli_arch}-apple-darwin.tar.gz"; do
    pairs="${pairs}${archive} $(lookup_sha "$archive")"$'\n'
  done
done

tmp="$(mktemp "$formula.XXXXXX")"
trap 'rm -f "$sums_file" "$tmp"' EXIT
PAIRS="$pairs" awk -v ver="$version" -v base="$base_url" '
  BEGIN {
    n = split(ENVIRON["PAIRS"], lines, "\n")
    for (i = 1; i <= n; i++) {
      split(lines[i], kv, " ")
      if (kv[1] != "") sha_of[kv[1]] = kv[2]
    }
  }
  /^  # placeholder hash/ { next }
  /^ +url "/ {
    line = $0
    gsub(/\/v[0-9]+\.[0-9]+\.[0-9]+\//, "/v" ver "/", line)
    name = line
    sub(/^[^"]*"/, "", name); sub(/"$/, "", name); sub(/^.*\//, "", name)
    sub(/-[0-9]+\.[0-9]+\.[0-9]+\.zip$/, "-" ver ".zip", name)
    sub(/^meshtown-cli-[0-9]+\.[0-9]+\.[0-9]+-/, "meshtown-cli-" ver "-", name)
    if (base != "") {
      match($0, /^ +/)
      line = substr($0, 1, RLENGTH) "url \"" base "/" name "\""
    } else {
      sub(/[^\/"]*"$/, name "\"", line)
    }
    cur = name
    urls++
    print line
    next
  }
  /^ +sha256 "/ {
    if (!(cur in sha_of)) { print "bump.sh: no sha256 for url of " cur > "/dev/stderr"; exit 1 }
    match($0, /^ +/)
    print substr($0, 1, RLENGTH) "sha256 \"" sha_of[cur] "\""
    shas++
    next
  }
  { print }
  END {
    if (urls != 5 || shas != 5) { print "bump.sh: expected 5 url and 5 sha256 lines, found " urls " and " shas > "/dev/stderr"; exit 1 }
  }
' "$formula" > "$tmp" || die "cannot update $formula"
chmod --reference="$formula" "$tmp" 2>/dev/null || chmod 0644 "$tmp"
mv "$tmp" "$formula"
rm -f "$sums_file"
trap - EXIT
echo "bumped $(basename "$formula") to $version"
