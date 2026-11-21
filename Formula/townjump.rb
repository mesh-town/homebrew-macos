class Townjump < Formula
  desc "Share a local port over a peer-to-peer tunnel; Rust port of Holesail"
  homepage "https://mesh-town.github.io/townjump/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/townjump/releases/download/v0.1.27/SHA256SUMS"
  sha256 "ba63c838920a4e159cd2d2615715d808f5785f4567dfeb44f9e4691d470bd2a8"
  license "AGPL-3.0-only"

  depends_on :macos

  resource "binary" do
    on_arm do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.27/townjump-0.1.27-aarch64-apple-darwin.tar.gz"
      sha256 "3605dd9edf767c4211a5ab0e7d8bb9a078605a59885e7e2669b5a5bfe2e13641"
    end

    on_intel do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.27/townjump-0.1.27-x86_64-apple-darwin.tar.gz"
      sha256 "73b3e7ec08acebf1f4f323c792eccc40190821ca6c41ebfaaa97f2a82ac63a31"
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
