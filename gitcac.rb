require 'formula'

class Gitcac < Formula
  homepage 'https://github.com/dustinparker/homebrew-gitcac'
  url 'https://raw.github.com/dustinparker/homebrew-gitcac-binaries/master/gitcac-1.0.tar.gz'
  sha1 '0e021352459225fe17d95887760ca2c858540db8'

  depends_on 'dustinparker/gitcac/git'

  def install
    system "make"
  end
end
