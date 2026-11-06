class Townjump < Formula
  desc "Share a local port over a peer-to-peer tunnel; Rust port of Holesail"
  homepage "https://mesh-town.github.io/townjump/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/townjump/releases/download/v0.1.20/SHA256SUMS"
  sha256 "47561f7f9611b35a7d1e0c29097080ae666842bb64ea3ec16fe74e5e9b141609"
  license "AGPL-3.0-only"

  depends_on :macos

  resource "binary" do
    on_arm do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.20/townjump-0.1.20-aarch64-apple-darwin.tar.gz"
      sha256 "6441a7ead0e8e23564d8799861b54fb6611c1073467d9d91e4b5c48389ae6e26"
    end

    on_intel do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.20/townjump-0.1.20-x86_64-apple-darwin.tar.gz"
      sha256 "e50f65f6353c2914d95c92601b1d517619b5c432c9413f46e323b356b6189521"
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
