class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.96/SHA256SUMS"
  sha256 "f2d100c38d39ac1d6392d74c2052be63cc04842a7324a16ae552387e265fb32f"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.96/MeshTown-macos-arm64-0.3.96.zip"
      sha256 "cf6233e0e893071e0a00ce6a8a96fadbfcfccb86a1c8502dc824f5387b682968"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.96/meshtown-cli-0.3.96-aarch64-apple-darwin.tar.gz"
      sha256 "a558ece7a5f1e7ef95fddd8a2c1955c4e10e385dc9b249c3b7e0994fcd9855c5"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.96/MeshTown-macos-x86_64-0.3.96.zip"
      sha256 "ecb0144774a2b35a09bf1283c026271ff7b7faaafa791c78b6c0649c90818820"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.96/meshtown-cli-0.3.96-x86_64-apple-darwin.tar.gz"
      sha256 "8946e5c9194f9373cf2727d13aa3ff79e86dbf503845f847510979792eb8a114"
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
