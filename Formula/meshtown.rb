class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.26/SHA256SUMS"
  sha256 "5a3da8e2967fc77d0e809315ec14ddf740754744539f7831a63a7f66edb8b265"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.26/MeshTown-macos-arm64-0.3.26.zip"
      sha256 "093e40434825cef273a74c1939ec49ad3810aa5517a02b2f8431a112f2dcaf46"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.26/meshtown-cli-0.3.26-aarch64-apple-darwin.tar.gz"
      sha256 "99af8c106e5afd332ce474fb8f117951d92cb5ddf683015213d9cfd87415bb7b"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.26/MeshTown-macos-x86_64-0.3.26.zip"
      sha256 "f5311cb606585a105356ee71d68c9c9c6cdaa7747f404e262c4bbed8bf2fdb9e"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.26/meshtown-cli-0.3.26-x86_64-apple-darwin.tar.gz"
      sha256 "8fa4cd08c684f408df081d5e80a944a74078a4abd434165aae8dbda813ef461c"
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
