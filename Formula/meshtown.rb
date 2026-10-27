class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.163/SHA256SUMS"
  sha256 "924b9839a300d1d5c97617c04b194d04f45b015eeb90786f7fbe2cf598f09a65"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.163/MeshTown-macos-arm64-0.3.163.zip"
      sha256 "1c1dee92e16409e8f47a567dd9406dda336c96f0752223d26f57a01ee2eeab69"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.163/meshtown-cli-0.3.163-aarch64-apple-darwin.tar.gz"
      sha256 "5a9776e48a9fb9ea1004feb9b9703f8668ef7cbe192424a1748846824dc31daf"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.163/MeshTown-macos-x86_64-0.3.163.zip"
      sha256 "8346fd64f5794f158b3dee057ad0572ec5194ec12fcc6ad682a330649ff74c57"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.163/meshtown-cli-0.3.163-x86_64-apple-darwin.tar.gz"
      sha256 "5ecbb7cc9019a7a6a406e4d2da891edca04808b7ca4790c3fcc43fb3cd3de846"
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
