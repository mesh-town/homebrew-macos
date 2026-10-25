# Mesh Town Homebrew tap

**Mesh Town** connects your computers, phones and routers into a private network and lets you reach the services
running on them from anywhere — SSH, RDP, the web panel of a NAS or router — with no port forwarding, no public IP,
no central server and no account to create. Nodes find each other on the public DHT and connect directly, and keep
reconnecting when a device changes networks. A member can also act as an exit node: a local SOCKS5/HTTP proxy sends
traffic out through a trusted member's connection. Main repository and documentation:
[mesh-town/meshtown](https://github.com/mesh-town/meshtown).

Homebrew tap for Mesh Town on macOS, Apple silicon (arm64) and Intel (x86_64).

## Install

```sh
brew install mesh-town/meshtown/meshtown
```

This adds the tap and installs the formula in one step. Homebrew 7 and newer loads formulae only from
third-party taps you trust, and installing by the full name above trusts the formula.

If you ran `brew tap mesh-town/meshtown` first, `brew install meshtown` stops with "Refusing to load formula
... from untrusted tap". Run `brew trust mesh-town/meshtown` (Homebrew 7 and newer) and install again.

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
rewrites the version inside both `url`s (the app and the `cli` resource) and both `sha256`s in `Formula/meshtown.rb`. `scripts/bump_test.sh` tests the script
offline. The `check` workflow runs `brew style`, `brew audit --strict` and those tests.

## Licenses

This tap: BSD-2-Clause (see `LICENSE`). Mesh Town itself: AGPL-3.0-only.
