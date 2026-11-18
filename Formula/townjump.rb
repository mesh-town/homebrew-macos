class Townjump < Formula
  desc "Share a local port over a peer-to-peer tunnel; Rust port of Holesail"
  homepage "https://mesh-town.github.io/townjump/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/townjump/releases/download/v0.1.24/SHA256SUMS"
  sha256 "dd4c4abbe72b2481af3224955e25b0157e414549c97fe72479e40d190317b2de"
  license "AGPL-3.0-only"

  depends_on :macos

  resource "binary" do
    on_arm do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.24/townjump-0.1.24-aarch64-apple-darwin.tar.gz"
      sha256 "488857b08fd812c35796120d031614c02dd2966bb0eb019459119284fb30e5a3"
    end

    on_intel do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.24/townjump-0.1.24-x86_64-apple-darwin.tar.gz"
      sha256 "6926dd241827803318cac1961efe2cb3d1969438d9c2d8702e9a83765b014061"
    end
  end

  def install
    resource("binary").stage { bin.install "townjump" }
  end

  def caveats
    <<~EOS
      This package installs a command named `townjump`, so it does not
      collide with the npm package `holesail` (`npm i -g holesail`). The help
      and messages it prints still say `holesail`, as in the original.
      Unofficial Rust port, not affiliated with Holesail / LIVEPORT.
    EOS
  end

  test do
    assert_match "Holesail CLI", shell_output("#{bin}/townjump --help")
  end
end
