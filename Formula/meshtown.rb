class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://mesh-town.github.io/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.304/SHA256SUMS"
  sha256 "840ffbc53714b56dc46938c33d8ac319ba6219e6c0e4c24324ff3c3837bd4c06"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.304/MeshTown-macos-arm64-0.3.304.zip"
      sha256 "1d71b15922dad980f5edf57298e4f6b7daf32b15d6ec53751c7677c5dceaa803"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.304/meshtown-cli-0.3.304-aarch64-apple-darwin.tar.gz"
      sha256 "95866b6def42874dbcad848ef043bb368e6b733d7d7c812de8f6ec3da0d5a4c0"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.304/MeshTown-macos-x86_64-0.3.304.zip"
      sha256 "889536cce81b8f9895a1f65cc442eeb3cf562869fc2d22badf4e135116cfdae8"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.304/meshtown-cli-0.3.304-x86_64-apple-darwin.tar.gz"
      sha256 "4b398fbae17b031596678cbfd5f134afe7c54e9a922fe5743d680b820ca0fc44"
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
