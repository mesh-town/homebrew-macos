class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://mesh-town.github.io/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.335/SHA256SUMS"
  sha256 "42a5174e1aa17661f860b3a40a81b8318f58f4163332c01c2ad4778640c4b592"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.335/MeshTown-macos-arm64-0.3.335.zip"
      sha256 "5fd1c749a711d00187383ad3fc94c99ffa0c0921122d8348ccd744551213d35b"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.335/meshtown-cli-0.3.335-aarch64-apple-darwin.tar.gz"
      sha256 "cf5cd64b1bf453f54242d70c959164cb34a50118bcd2eb0450c94727215f6f05"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.335/MeshTown-macos-x86_64-0.3.335.zip"
      sha256 "cff95f9e2764e590c6ac720a1318596624b66b46cf2972ef88bd62b53ef8edca"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown-dist/releases/download/v0.3.335/meshtown-cli-0.3.335-x86_64-apple-darwin.tar.gz"
      sha256 "69885b37cb23ade951ca6019dc055a07bafc8e76a134a623473c0981202ae7e4"
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
