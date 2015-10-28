require 'formula'

class Cackey < Formula
  homepage 'https://github.com/jigsawpub/homebrew-gitcac'
  url 'https://raw.github.com/jigsawpub/homebrew-gitcac-binaries/master/CACKey_0.7.5_Slandup.pkg.tar.gz'
  sha512 'f63976362cdf7beb92556273b72d278c41e10ed71dc4a32d498b543e39c09cfc204cbed7bd89bed27f1af79d77cfc5e27aba64b0a1ee6485bdd3dfafc1b2057f'

  def install
    ohai 'Installing cackey library; this requires admin privileges.'
    system "sudo", "/usr/sbin/installer", "-pkg", ".", "-target", "/"
  end
end
