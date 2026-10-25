class Meshtown < Formula
  desc "Reach the services on your devices from anywhere, no central server or accounts"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.116/SHA256SUMS"
  sha256 "5c655de849943e192a0e7738bed90f4d67d9cccfc698ba9113c39e3345514a00"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.116/MeshTown-macos-arm64-0.3.116.zip"
      sha256 "c9395b718f83a6e5b2f1477e18aa67bcdb431143e44a1813a29a44387accebd7"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.116/meshtown-cli-0.3.116-aarch64-apple-darwin.tar.gz"
      sha256 "bdbc03fc06f3d60e51411561745e8dce741d31c03613d6db73a89c39957aa222"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.116/MeshTown-macos-x86_64-0.3.116.zip"
      sha256 "65642e050216c9fb0dc9cad9462922298daf408bacd1014b071285bdc06cb180"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.116/meshtown-cli-0.3.116-x86_64-apple-darwin.tar.gz"
      sha256 "290797996bae84cc7427ee49cef10528d84b2d1fc86891c2e0c76c4fc662a463"
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
