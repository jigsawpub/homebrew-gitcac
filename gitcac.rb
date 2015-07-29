require 'formula'

class Gitcac < Formula
  homepage 'https://github.com/jigsawpub/homebrew-gitcac'
  url 'https://raw.github.com/jigsawpub/homebrew-gitcac-binaries/master/gitcac-2.0.tar.gz'
  version '2.0'
  sha256 '8217f4a4b4f8bbeec676ef3cf247e119855fcf2e94033a5cb86cde2129db42b7'

  depends_on 'engine_pkcs11'
  depends_on 'cackey'
  depends_on 'gitcac-git'

  def install
    ohai 'Installing gitcac files...'
    system "make"
    if (which('curl') == '/usr/bin/curl')
        opoo 'Your current $PATH does not check /usr/local/bin before /usr/bin.'
        opoo 'Check /etc/paths and ensure /usr/local/bin is the first entry.'
    end
  end

  def caveats
      <<-EOS.undent
          To use gitcac, add this line to your ~/.bash_profile:

              export OPENSSL_CONF=/usr/local/etc/gitcac-openssl.cnf

          To configure git for your specific repo, issue commands like these

              git config --global 'http.https://hostname.example.com/.sslengine' pkcs11
              git config --global 'http.https://hostname.example.com/.sslkeytype' ENG
              git config --global 'http.https://hostname.example.com/.sslcerttype' ENG
      EOS
  end
end
