class Meshtown < Formula
  desc "Open websites through the computers of your network's members"
  homepage "https://github.com/mesh-town/meshtown"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/meshtown/releases/download/v0.3.25/SHA256SUMS"
  sha256 "52464d0caef975a370ec9780a117893519459f84287822b0585a570b4c66451d"
  license "AGPL-3.0-only"

  depends_on :macos

  on_arm do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.25/MeshTown-macos-arm64-0.3.25.zip"
      sha256 "e9b0b25c611c4dfda3f126eb0ae0553d694fb32a1c49fdbd4c7ca0153a67d16d"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.25/meshtown-cli-0.3.25-aarch64-apple-darwin.tar.gz"
      sha256 "5dfc44d4e248f1bb549e5d04d1e17c39798f26f59e9fdcf6f192b8e6c991af39"
    end
  end

  on_intel do
    resource "app" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.25/MeshTown-macos-x86_64-0.3.25.zip"
      sha256 "89373417dd9d537eeafb9254602d6d967493270941017d04d7611919c4fa75aa"
    end

    resource "cli" do
      url "https://github.com/mesh-town/meshtown/releases/download/v0.3.25/meshtown-cli-0.3.25-x86_64-apple-darwin.tar.gz"
      sha256 "5ddef97c0fc0deddfb9b1c2d3cfa72881f3fa33ca1b4838230db31cbbe34f351"
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
