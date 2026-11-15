class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://mesh-town.github.io/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.362/SHA256SUMS"
  sha256 "c5515056612e789e4ab8f7d2bbd8a144801d31f3bd97fe894f5500f8be0b3501"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.362/MeshTown-macos-arm64-0.3.362.zip"
      sha256 "1ce8e6f41648442826ee67b7d8485892d91ae388d791f483b01accbc37453dce"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.362/meshtown-cli-0.3.362-aarch64-apple-darwin.tar.gz"
      sha256 "4c4632d047b531f834dbcd97fe713715e8910c8dc133d6fb0e46247fd820ed96"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.362/MeshTown-macos-x86_64-0.3.362.zip"
      sha256 "4f155ae58f16de8689bb61fc4d79b52f549b18c697081290f1e19b4b783dd8e2"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.362/meshtown-cli-0.3.362-x86_64-apple-darwin.tar.gz"
      sha256 "cf851f101a7482bbbbb1288bdaac9ce975978c1e158015ba75cfc506e836ba07"
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
