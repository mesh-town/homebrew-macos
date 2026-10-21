class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.30/SHA256SUMS"
  sha256 "2a83169fe27073db834344293e2b768ac0d6816d6dc83aaa44252ed614a7cc0e"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.30/MeshTown-macos-arm64-0.3.30.zip"
      sha256 "e67a9f9101c8280fb56eb944cb20ae75ba590c51a7e6f709b0253352f8cc2d69"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.30/meshtown-cli-0.3.30-aarch64-apple-darwin.tar.gz"
      sha256 "279dfea81b0ae9197a9935dbd874ed0cdb3c3fa97f38c405beb6ea5f9ff411e6"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.30/MeshTown-macos-x86_64-0.3.30.zip"
      sha256 "fb8e71b391101876b9692af459e8b6bcc44c631e27d1d2cbba36c09a9054d78c"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.30/meshtown-cli-0.3.30-x86_64-apple-darwin.tar.gz"
      sha256 "b560686589c135400469fa1c427177492e9fd2e387b96ccf3b61a359a0484a89"
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
