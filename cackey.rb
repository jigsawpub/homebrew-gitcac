require 'formula'

class Cackey < Formula
  homepage 'https://github.com/jigsawpub/homebrew-gitcac'
  url 'https://raw.github.com/jigsawpub/homebrew-gitcac-binaries/master/CACKey_0.7.5_Slandup.pkg.tar.gz'
  sha256 '66aa807f7138bf6d440700897a1c6d2912721b0a6409b15b779440936fb71765'

  def install
    ohai 'Installing cackey library; this requires admin privileges.'
    system "sudo", "/usr/sbin/installer", "-pkg", ".", "-target", "/"
  end
end
