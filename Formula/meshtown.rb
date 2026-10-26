class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.150/SHA256SUMS"
  sha256 "dd5eb0ff547683ea32a4cb4165c74f38ac0f25d41c1c5c5fa0d1558b5901a7b5"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.150/MeshTown-macos-arm64-0.3.150.zip"
      sha256 "caa44c9c00c814064bbb1f01dd2f87c71fd184ae62fec61ce67a9bd775385a15"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.150/meshtown-cli-0.3.150-aarch64-apple-darwin.tar.gz"
      sha256 "6ac3ce7cea72a984fac1f7e1601181d6ae449164e4ba46c79e6fefd1ba9b1ffb"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.150/MeshTown-macos-x86_64-0.3.150.zip"
      sha256 "ea802ac92d71eaa578ba229e9447f3df1f6ab2a15ac14566e06779c155179eaf"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.150/meshtown-cli-0.3.150-x86_64-apple-darwin.tar.gz"
      sha256 "0d22a227fc98c40166f61e8c5ab9b9a0e81648d5154a5f7d8c7cf56b4aa77684"
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
