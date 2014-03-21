require 'formula'

class Gitcac < Formula
  homepage 'https://github.com/dustinparker/homebrew-gitcac'
  url 'https://raw.github.com/dustinparker/homebrew-gitcac-binaries/master/gitcac-1.0.tar.gz'
  sha1 '862a376c4b8863f835e583c52c97110ef6510aea'

  depends_on 'dustinparker/gitcac/git'

  def install
    system "make"
  end
end
