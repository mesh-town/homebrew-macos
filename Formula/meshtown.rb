class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.195/SHA256SUMS"
  sha256 "790310d62f7b61e81805db32d1cb3010c405acedadd440b9d92e2c2ef7af30eb"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.195/MeshTown-macos-arm64-0.3.195.zip"
      sha256 "2d8910df229d27586ceaf8b12329e6826ab65079a257095b0cdc90680a427904"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.195/meshtown-cli-0.3.195-aarch64-apple-darwin.tar.gz"
      sha256 "46c7edcfb9d10621083b55ca58d302219e3e46bb79a7383af88c4499abf96186"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.195/MeshTown-macos-x86_64-0.3.195.zip"
      sha256 "bcb10710ed3ba12768620abb8a54bed49c0ae3e136c23683171c2ee17291b135"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.195/meshtown-cli-0.3.195-x86_64-apple-darwin.tar.gz"
      sha256 "e6f44045cc595deba8404086db6f0831dbcb328c3afada8431559bab17dd7482"
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
