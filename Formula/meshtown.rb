class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.1/SHA256SUMS"
  sha256 "e623f1d985a164c362c7d77f55e16b49ed612d57a2a4ee4a1629cc711fdd80ad"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.1/MeshTown-macos-arm64-0.3.1.zip"
      sha256 "f7d7ba1311a838a2f333b670cb18aa701924ba93aa6e8ca16b77991f3d309956"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.1/meshtown-cli-0.3.1-aarch64-apple-darwin.tar.gz"
      sha256 "caf17412056526a5ddd17ce15b6f0d5363522cad7b613de76773479e2a980a9f"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.1/MeshTown-macos-x86_64-0.3.1.zip"
      sha256 "615d0db58ccab5b2b690d3f27a053ecca3b255f9cdb9d4a9cbbe4a8f109d2f4c"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.1/meshtown-cli-0.3.1-x86_64-apple-darwin.tar.gz"
      sha256 "2be3ea1cc8b740247794fc571a374c22f069f0cfc410fbbab0493cc1385dc523"
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
