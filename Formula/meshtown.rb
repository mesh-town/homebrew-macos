class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.178/SHA256SUMS"
  sha256 "4a7a7fb989ae16a32eaf0d9dfe3b3db43975f028485a246b362c32d8a9400bd0"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.178/MeshTown-macos-arm64-0.3.178.zip"
      sha256 "9c90a961daabec6fbfab4f175ae68c243c2e03ed9c51119e6267f0e3b556997d"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.178/meshtown-cli-0.3.178-aarch64-apple-darwin.tar.gz"
      sha256 "5c8dca900aaec8f152cdacf46f54bd7ba726ac6bc35a7e02aaba5230986db1cd"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.178/MeshTown-macos-x86_64-0.3.178.zip"
      sha256 "e9cc2bb859b3a9a8823eb58fc0dbae36363b44e18b1ac7aa1361a5684bcc4158"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.178/meshtown-cli-0.3.178-x86_64-apple-darwin.tar.gz"
      sha256 "82695e3a7bc366be9df5731489b3190530654890291bd2ae72b10ed811f60a30"
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
