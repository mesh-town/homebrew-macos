class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.187/SHA256SUMS"
  sha256 "dd96f594d24094c5eef102648561bae7816c12aec71bb29b2f6d144a8126f153"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.187/MeshTown-macos-arm64-0.3.187.zip"
      sha256 "4bbdb2597930fabe1b99b869f904f0d3d1319eae1dee3b407dffb9e2588cbd4d"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.187/meshtown-cli-0.3.187-aarch64-apple-darwin.tar.gz"
      sha256 "8f2447f37ec1e48fb2b7cdd3633c0f6cc9719c1963bbb56977795bc191921752"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.187/MeshTown-macos-x86_64-0.3.187.zip"
      sha256 "919d274fa6294d7aa8e29fe05cdd856082f17229bdfbfe43aab0621d484043c0"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.187/meshtown-cli-0.3.187-x86_64-apple-darwin.tar.gz"
      sha256 "410f0889580ac1bbe3b6edb9c89d28c5cd8249a658ae7a516769796fce3553d8"
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
