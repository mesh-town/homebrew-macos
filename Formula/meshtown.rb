class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.29/SHA256SUMS"
  sha256 "d09937b0346809aa80315e0bfd90a444195d715d1a36bbc43f62807f65ae18b3"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.29/MeshTown-macos-arm64-0.3.29.zip"
      sha256 "05a0f547241db0d4ef1de0b8d3fded934ce9ee1011c82e8d2cf3364c2381ff7d"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.29/meshtown-cli-0.3.29-aarch64-apple-darwin.tar.gz"
      sha256 "636c1e45e402ceb5d1bf48cf814d5e8c6f687c56bde16a205d07c5eabbb792cc"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.29/MeshTown-macos-x86_64-0.3.29.zip"
      sha256 "faaa7a39527ff2ef03cf5036b92a0e82603e7b4ea0bbe3202605c0fb27357c01"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.29/meshtown-cli-0.3.29-x86_64-apple-darwin.tar.gz"
      sha256 "98854d2aecd09d8a4e7f31b8178a5f052acc0fcedce5a0acd1645f440be052b6"
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
