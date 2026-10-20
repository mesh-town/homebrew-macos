class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.14/SHA256SUMS"
  sha256 "a650029941e5f2083ca45538ba58db7e7de96e53ef1f3af79d88db6445d64d3c"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.14/MeshTown-macos-arm64-0.3.14.zip"
      sha256 "c7e26f2f565a43148a562979c3ba186e2b22d7843bec8911c82516eb6f494d54"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.14/meshtown-cli-0.3.14-aarch64-apple-darwin.tar.gz"
      sha256 "55db8dadcd0b0e848f61735913ef24eb000ba10286d2d18d742eb80b1c2ad4b2"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.14/MeshTown-macos-x86_64-0.3.14.zip"
      sha256 "8317f4cdc40be0800a7720bf2c2f2dc50162bd17ca4e66e853b4354adf4b9477"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.14/meshtown-cli-0.3.14-x86_64-apple-darwin.tar.gz"
      sha256 "e52b5c88e099e4e65a751b106ad385187f12778d1f73c81d143f22e552a5c120"
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
