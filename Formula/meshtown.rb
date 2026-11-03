class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://mesh-town.github.io/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.278/SHA256SUMS"
  sha256 "4faf35c7562d9f392910b72c5822c2da3d059d551553e57ab900d12a427813d0"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.278/MeshTown-macos-arm64-0.3.278.zip"
      sha256 "9d01a2b58806a081ea6820f160e66ef69cfb8342f6e0f0afde7e4744d3ce8a63"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.278/meshtown-cli-0.3.278-aarch64-apple-darwin.tar.gz"
      sha256 "e90cf155886ecbf56ed8518866741b057e210f83f77e5c8feeb8c17fe69d8084"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.278/MeshTown-macos-x86_64-0.3.278.zip"
      sha256 "69dea44b1dd7b922227345589584a3a27fbb62820ae5ddc25cc3dde08a38411b"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.278/meshtown-cli-0.3.278-x86_64-apple-darwin.tar.gz"
      sha256 "d2a63234c44bf3df44c399b08fe31df1ea57c62d34035552cffe9c05c85b5239"
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
