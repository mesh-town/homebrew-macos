class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://mesh-town.github.io/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.225/SHA256SUMS"
  sha256 "59e8723f68653e8ebd393c69dbf6df93dd0a54291cae27a06b623d1f6cc448a0"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.225/MeshTown-macos-arm64-0.3.225.zip"
      sha256 "605bd5736cf5641a3509c12eefb1507c88d60b00a0c62dd8190fad2c04e36cf9"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.225/meshtown-cli-0.3.225-aarch64-apple-darwin.tar.gz"
      sha256 "d268ef04f6f90df0c3effdf2b347a2d4b2275f181a7d0202ec04faccd1cd4175"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.225/MeshTown-macos-x86_64-0.3.225.zip"
      sha256 "8f76489391b4e48b9fe09178109841a0818228826eaee838650267fcd11e724a"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.225/meshtown-cli-0.3.225-x86_64-apple-darwin.tar.gz"
      sha256 "0992f9d9feb26866297619a2efe41c782437ba18d76569a0dcf6a128e7e4c4c7"
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
