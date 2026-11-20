class Townjump < Formula
  desc "Share a local port over a peer-to-peer tunnel; Rust port of Holesail"
  homepage "https://mesh-town.github.io/townjump/"
  # The checksum list of the release pins the archives below.
  url "https://github.com/mesh-town/townjump/releases/download/v0.1.26/SHA256SUMS"
  sha256 "461a33b411a1c9002eed039f803ca99a54dc06f3db7e421e54cb5e6a9202f11f"
  license "AGPL-3.0-only"

  depends_on :macos

  resource "binary" do
    on_arm do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.26/townjump-0.1.26-aarch64-apple-darwin.tar.gz"
      sha256 "463a1cf5620be545481abfd57e255a16ef645adaf604e7df4fda4e6c26422795"
    end

    on_intel do
      url "https://github.com/mesh-town/townjump/releases/download/v0.1.26/townjump-0.1.26-x86_64-apple-darwin.tar.gz"
      sha256 "924b6fb931efa28e1fd2eff2b99d278f8fb4bb9a2da6f7265832095b0d5628ab"
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
