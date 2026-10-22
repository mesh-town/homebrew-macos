class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.33/SHA256SUMS"
  sha256 "69e0e6e1a29a9b4cee601eb02c4668d322e6f1a0ceb77dde6c9fef988beaec47"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.33/MeshTown-macos-arm64-0.3.33.zip"
      sha256 "3c49d9a979c2e5de26fe1deccb567c22dc40e9483069c87e27119ec167799322"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.33/meshtown-cli-0.3.33-aarch64-apple-darwin.tar.gz"
      sha256 "2e762e19179b51c7ca63368012f1c368d5d6d4b97aacecec5d54cb103d2b1445"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.33/MeshTown-macos-x86_64-0.3.33.zip"
      sha256 "7525e222cb702b72462b5790f6314b9dee2467c3ef61959a69f393a3e2f2daca"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.33/meshtown-cli-0.3.33-x86_64-apple-darwin.tar.gz"
      sha256 "a233fea51d7a3378121120ec036d623d71673d1ff193a585a8680aa12648edd3"
    end
  end

  def install
    resource("app").stage { (prefix/"MeshTown.app").install Dir["*"] }

    (bin/"meshtown").write <<~SH
      #!/bin/sh
      app="#{opt_prefix}/MeshTown.app"
      if [ "$#" -eq 0 ]; then
        exec open "$app"
      fi
      exec "$app/Contents/MacOS/meshtown" "$@"
    SH
    chmod 0755, bin/"meshtown"

    resource("cli").stage { bin.install "meshtown-cli" }
  end

  def caveats
    <<~EOS
      The app is installed at:
        #{opt_prefix}/MeshTown.app

      Run `meshtown` to start the menu bar icon, or `meshtown --help` for the command line help.

      Run `meshtown-cli` to run the node in this terminal without the menu bar icon; Ctrl+C stops it.
      It shares its settings with the app, so do not run both at the same time.

      `brew upgrade` does not restart a running app: quit it from the menu bar icon,
      then run `meshtown` again.

      The build is ad-hoc signed and not notarized. Homebrew does not set the
      quarantine flag, so Gatekeeper shows no prompt. No root access and no
      background services are needed.

      Settings and logs are kept in:
        ~/Library/Application Support/meshtown/
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/meshtown --version")
    assert_match version.to_s, shell_output("#{bin}/meshtown-cli --version")
  end
end
