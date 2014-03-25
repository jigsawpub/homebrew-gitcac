require 'formula'

class Curl < Formula
  homepage 'http://curl.haxx.se/'
  url 'http://curl.haxx.se/download/curl-7.35.0.tar.gz'
  # We want to be used in preference to homebrew's curl
  version '9999.7.35.0'
  mirror 'ftp://ftp.sunet.se/pub/www/utilities/curl/curl-7.35.0.tar.gz'
  sha256 '917d118fc5d61e9dd1538d6519bd93bbebf2e866882419781c2e0fdb2bc42121'

  bottle do
    root_url "https://raw.github.com/dustinparker/homebrew-gitcac-binaries/master"
    sha1 "0f5dd2365f4b6c4c4ec8ce482910e56d8808f9cd" => :mavericks
  end

  option 'with-ssh', 'Build with scp and sftp support'
  option 'with-ares', 'Build with C-Ares async DNS support'
  option 'with-gssapi', 'Build with GSSAPI/Kerberos authentication support.'

  if MacOS.version >= :mountain_lion
    option 'with-openssl', 'Build with OpenSSL instead of Secure Transport'
    depends_on 'openssl' => :optional
  else
    depends_on 'openssl'
  end

  depends_on 'pkg-config' => :build
  depends_on 'libmetalink' => :optional
  depends_on 'libssh2' if build.with? 'ssh'
  depends_on 'c-ares' if build.with? 'ares'

  def patches
      [ "file:///#{File.dirname(@path)}/curl-7.35.0.patch" ]
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--with-ssl=#{Formula.factory("openssl").opt_prefix}"

    args << "--with-libssh2" if build.with? 'ssh'
    args << "--with-libmetalink" if build.with? 'libmetalink'
    args << "--enable-ares=#{Formula.factory("c-ares").opt_prefix}" if build.with? 'ares'
    args << "--with-gssapi" if build.with? 'gssapi'
    args << "--with-ca-bundle=/System/Library/OpenSSL/certs/dod_ca_chain.pem"

    system "./configure", *args
    system "make install"
  end
end
