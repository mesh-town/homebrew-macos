class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.191/SHA256SUMS"
  sha256 "721bcb5cf9bb87349627a35e9cbf4398c7c21b71284918f9a5b33a2e8ae9d6b1"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.191/MeshTown-macos-arm64-0.3.191.zip"
      sha256 "f4f1ca1dea1ccb2ea01b10c83130d8db775cbbe06f91dc24af3ad74f9a95612d"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.191/meshtown-cli-0.3.191-aarch64-apple-darwin.tar.gz"
      sha256 "1227650a66ec97e6108e98d77e478bca2d2596c705fb813e25b0d954529f4e75"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.191/MeshTown-macos-x86_64-0.3.191.zip"
      sha256 "4845591044d101e72694171aeae346b809c1e4e9d873dcc421f140458a61cf81"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.191/meshtown-cli-0.3.191-x86_64-apple-darwin.tar.gz"
      sha256 "c35b0520033f0fdc7acd2adb5972603e8d1a91ab2a4102b20ec32372a45e1856"
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
