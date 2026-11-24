# Mesh Town Homebrew tap

**[Mesh Town](https://mesh-town.github.io/)** — reach your home server, NAS or office PC from anywhere: no port
forwarding, no central server, no accounts.

Mesh Town links your own computers, phones and routers directly, so you can open a NAS panel, SSH into a home
server or use a work PC by remote desktop from any network. It is free and open source, for macOS, Windows, Linux,
Android and OpenWrt or Keenetic routers.

- Website: [mesh-town.github.io](https://mesh-town.github.io/)
- Source and documentation: [mesh-town/meshtown](https://github.com/mesh-town/meshtown)

This is the Homebrew tap for Mesh Town on macOS, Apple silicon (arm64) and Intel (x86_64).

## Install

```sh
brew install mesh-town/macos/meshtown
```

This adds the tap and installs the formula in one step. Homebrew 7 and newer loads formulae only from
third-party taps you trust, and installing by the full name above trusts the formula.

`brew install mesh-town/macos/mesh-town` works too: `Formula/mesh-town.rb` is the same formula under the other
spelling of the name. The two cannot be installed at the same time.

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

The `bump` workflow runs daily, on a release notification, or manually from the Actions tab (with an optional
version). It takes the given version, or the latest release of `mesh-town/meshtown-dist`, and runs
`scripts/bump.sh <version>`. The script:

1. reads `SHA256SUMS` of that release;
2. rewrites the version in the five `url`s of `Formula/meshtown.rb`: `SHA256SUMS`, then the app zip and the `cli`
   archive for arm64 and for Intel;
3. sets each `sha256` to the matching `SHA256SUMS` entry (for `SHA256SUMS` itself, the hash of the downloaded file).

Then `scripts/twin.sh` writes `Formula/mesh-town.rb` from `Formula/meshtown.rb`: only the class name and the name in
`conflicts_with` differ. Edit `meshtown.rb` only, then run `scripts/twin.sh`. An alias in `Aliases/` would not do:
Homebrew 7 refuses to install an alias from a tap the user has not trusted yet.

The workflow commits the change if the formula differs. `scripts/bump_test.sh` and `scripts/twin_test.sh` test the
scripts offline. The `check` workflow runs `brew style`, `brew audit --strict` on both formulae, checks that
`mesh-town.rb` is in sync, and runs those tests.

## Licenses

This tap: BSD-2-Clause (see `LICENSE`). Mesh Town itself: AGPL-3.0-only.
