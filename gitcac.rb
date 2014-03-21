require 'formula'

class Gitcac < Formula
  homepage 'https://github.com/dustinparker/homebrew-gitcac'
  url 'https://raw.github.com/dustinparker/homebrew-gitcac-binaries/master/gitcac-1.0.tar.gz'
  sha1 'ef963fd129455d992aafe063e062c97fab7cd485'

  depends_on 'dustinparker/gitcac/git'

  def install
    system "make"
  end
end
