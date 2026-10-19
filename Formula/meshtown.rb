class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  url "https://github.com/mesh-town/meshtown/releases/download/v0.2.5/MeshTown-macos-arm64-0.2.5.zip"
  sha256 "d3b1738615aa82e6fd4637e002796582c52d3602c6dbc34e08bef5f6943f9311"
  license "AGPL-3.0-only"

  depends_on arch: :arm64
  depends_on :macos

  resource "cli" do
    url "https://github.com/mesh-town/meshtown/releases/download/v0.2.5/meshtown-cli-0.2.5-aarch64-apple-darwin.tar.gz"
    sha256 "50f26f5ef39ec7868f2dc9e61774546ce7707fead56099d6a10a41beb68654a0"
  end

  def install
    (prefix/"MeshTown.app").install Dir["*"]

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
