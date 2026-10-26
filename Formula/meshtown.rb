class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.159/SHA256SUMS"
  sha256 "4170e2c5e32e1febc29682c184b9e4b3d4bb0607948b28c968e438103eaf3155"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.159/MeshTown-macos-arm64-0.3.159.zip"
      sha256 "f0db299d161e694abda0580797b75bb06af07c029232887c0520220a9152cb2d"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.159/meshtown-cli-0.3.159-aarch64-apple-darwin.tar.gz"
      sha256 "6c2f8137a3df29d8721ecb0f21d9acee8ef6a5478c26758a80e998b2d2061aac"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.159/MeshTown-macos-x86_64-0.3.159.zip"
      sha256 "92df02d9733ec3726d7eefacbc1b093d5d17e2bff7a6d9f3812186c1ae899627"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.159/meshtown-cli-0.3.159-x86_64-apple-darwin.tar.gz"
      sha256 "da6af4abf6555b73f5c09896f271683dabb5f78f7726ade4be741a834c0c1b21"
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
