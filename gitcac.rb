require 'formula'

class Gitcac < Formula
  homepage 'https://github.com/dustinparker/homebrew-gitcac'
  url 'https://raw.github.com/dustinparker/homebrew-gitcac-binaries/master/gitcac-1.0.tar.gz'
  sha1 'ea3618a46b67d6e7add8efd9c6c2625e2e15f568'

  depends_on 'engine_pkcs11'
  depends_on 'cackey'
  depends_on 'gitcac-git'

  def install
    ohai 'Installing gitcac files... You may have to supply your password to run \'sudo\'.'
    system "make"
    if (which('curl') == '/usr/bin/curl')
        opoo 'Your current $PATH does check /usr/local/bin before /usr/bin.'
        opoo 'Close this terminal or say \'exec bash -l\' to get an environment.'
        opoo 'If that does not work, check /etc/paths and ensure /usr/local/bin is the first entry.'
    end
  end

  def caveats
      <<-EOS.undent
        This script attempts to modify /etc/paths.

        If this is a new install, your current $PATH might not check /usr/local/bin before /usr/bin.
        Close and reopen this terminal or say 'exec bash -l' to get a fresh environment.
        If that does not work, check /etc/paths and ensure /usr/local/bin is the first entry.
      EOS
  end
end
