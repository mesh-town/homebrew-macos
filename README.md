# Mesh Town Homebrew tap

**[Mesh Town](https://mesh-town.github.io/)** — reach your home server, NAS or office PC from anywhere: no port
forwarding, no central server, no accounts.

Mesh Town links your own computers, phones and routers directly to each other, so you can open the web panel of a
NAS, SSH into a home server or connect to a work PC by remote desktop from any network. Free and open source, for
macOS, Windows, Linux, Android and OpenWrt or Keenetic routers. Website:
[mesh-town.github.io](https://mesh-town.github.io/) · source and documentation:
[mesh-town/meshtown](https://github.com/mesh-town/meshtown).

Homebrew tap for Mesh Town on macOS, Apple silicon (arm64) and Intel (x86_64).

## Install

```sh
brew install mesh-town/macos/meshtown
```

This adds the tap and installs the formula in one step. Homebrew 7 and newer loads formulae only from
third-party taps you trust, and installing by the full name above trusts the formula.

If you ran `brew tap mesh-town/macos` first, `brew install meshtown` stops with "Refusing to load formula
... from untrusted tap". Run `brew trust mesh-town/macos` (Homebrew 7 and newer) and install again.

## Run

```sh
meshtown          # starts the menu bar icon
meshtown --help   # command line help
meshtown-cli      # runs the node in this terminal, Ctrl+C stops it
```

## Upgrade

```sh
brew upgrade meshtown
```

`brew upgrade` does not restart a running app: quit it from the menu bar icon, then run `meshtown` again.

## Uninstall

```sh
brew uninstall meshtown
```

## Notarization

The build is ad-hoc signed and not notarized. Homebrew does not set the quarantine flag on
downloaded files, so Gatekeeper shows no prompt. No root access and no background services are needed.

## How the formula is updated

The `bump` workflow runs once a day (or manually from the Actions tab) and takes the latest release of
`mesh-town/meshtown`. It runs `scripts/bump.sh <version>`, which reads `SHA256SUMS` of that release and
rewrites the version in the five `url`s of `Formula/meshtown.rb` (`SHA256SUMS`, then the app zip and the `cli` archive for
arm64 and for Intel) and sets each `sha256` to the matching entry of `SHA256SUMS` (for `SHA256SUMS` itself, the hash of
the downloaded file). `scripts/bump_test.sh` tests the script offline. The `check` workflow runs `brew style`,
`brew audit --strict` and those tests.

## Licenses

This tap: BSD-2-Clause (see `LICENSE`). Mesh Town itself: AGPL-3.0-only.
