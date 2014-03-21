require 'formula'

class Gitcac < Formula
  homepage 'https://github.com/dustinparker/homebrew-gitcac'
  url 'https://raw.github.com/dustinparker/homebrew-gitcac-binaries/master/gitcac-1.0.tar.gz'
  sha1 '5bbbdfb1af670752133fa40c115145998f0f56af'

  depends_on 'engine_pkcs11'
  depends_on 'cackey'
  depends_on 'dustinparker/gitcac/git'

  def install
    ohai 'Installing gitcac files... You may have to supply your password to run \'sudo\'.'
    system "make"
  end
end
