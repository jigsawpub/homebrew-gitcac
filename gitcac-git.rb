class GitcacGit < Formula
  desc "Distributed revision control system (CAC enabled)"
  homepage "https://git-scm.com"
  url "https://www.kernel.org/pub/software/scm/git/git-2.5.0.tar.xz"
  sha256 "cc59b1bac6c1c67a9159872863f6c5bbe0d9404cac2a85c3e9d9fa49923ce45c"

  head "https://github.com/git/git.git", :shallow => false

  bottle do
    root_url "https://raw.github.com/jigsawpub/homebrew-gitcac-binaries/master"
    sha256 "bbe6f120f34cd663b8e0b4f83816cdf143d17f830c0c9d5f4d812ea085be01fc" => :yosemite
  end

  resource "man" do
    url "https://www.kernel.org/pub/software/scm/git/git-manpages-2.5.0.tar.xz"
    sha256 "1a6ea7220b1693eb384af0978a990ea8c0c634a7869d1ef63a2c8e427fc7f6ea"
  end

  resource "html" do
    url "https://www.kernel.org/pub/software/scm/git/git-htmldocs-2.5.0.tar.xz"
    sha256 "0924b290834e2a361a489cbc845a9bf04e56117597dc9c1a40e879cce655e4e2"
  end

  stable do
      patch :DATA
  end

  option "with-blk-sha1", "Compile with the block-optimized SHA1 implementation"
  option "without-completions", "Disable bash/zsh completions from 'contrib' directory"
  option "with-brewed-svn", "Use Homebrew's version of SVN"
  option "with-persistent-https", "Build git-remote-persistent-https from 'contrib' directory"

  depends_on "pcre" => :optional
  depends_on "gettext" => :optional
  depends_on "openssl"
  depends_on "gitcac-curl"
  depends_on "go" => :build if build.with? "persistent-https"
  # Trigger an install of swig before subversion, as the "swig" doesn't get pulled in otherwise
  # See https://github.com/Homebrew/homebrew/issues/34554
  if build.with? "brewed-svn"
    depends_on "swig"
    depends_on "subversion" => "with-perl"
  end

  def install
    # If these things are installed, tell Git build system to not use them
    ENV["NO_FINK"] = "1"
    ENV["NO_DARWIN_PORTS"] = "1"
    ENV["V"] = "1" # build verbosely
    ENV["NO_R_TO_GCC_LINKER"] = "1" # pass arguments to LD correctly
    ENV["PYTHON_PATH"] = which "python"
    ENV["PERL_PATH"] = which "perl"

    perl_version = /\d\.\d+/.match(`perl --version`)

    if build.with? "brewed-svn"
      ENV["PERLLIB_EXTRA"] = "#{Formula["subversion"].opt_prefix}/Library/Perl/#{perl_version}/darwin-thread-multi-2level"
    elsif MacOS.version >= :mavericks
      ENV["PERLLIB_EXTRA"] = %W[
        #{MacOS.active_developer_dir}
        /Library/Developer/CommandLineTools
        /Applications/Xcode.app/Contents/Developer
      ].uniq.map { |p|
        "#{p}/Library/Perl/#{perl_version}/darwin-thread-multi-2level"
      }.join(":")
    end

    unless quiet_system ENV["PERL_PATH"], "-e", "use ExtUtils::MakeMaker"
      ENV["NO_PERL_MAKEMAKER"] = "1"
    end

    ENV["BLK_SHA1"] = "1" if build.with? "blk-sha1"

    if build.with? "pcre"
      ENV["USE_LIBPCRE"] = "1"
      ENV["LIBPCREDIR"] = Formula["pcre"].opt_prefix
    end

    ENV["NO_GETTEXT"] = "1" if build.without? "gettext"

    args = %W[
      prefix=#{prefix}
      sysconfdir=#{etc}
      CC=#{ENV.cc}
      CFLAGS=#{ENV.cflags}
      LDFLAGS=#{ENV.ldflags}
    ]

    system "make", "install", *args

    # Install the OS X keychain credential helper
    cd "contrib/credential/osxkeychain" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-credential-osxkeychain"
      system "make", "clean"
    end

    # Install git-subtree
    cd "contrib/subtree" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-subtree"
    end

    if build.with? "persistent-https"
      cd "contrib/persistent-https" do
        system "make"
        bin.install "git-remote-persistent-http",
                    "git-remote-persistent-https",
                    "git-remote-persistent-https--proxy"
      end
    end

    if build.with? "completions"
      # install the completion script first because it is inside "contrib"
      bash_completion.install "contrib/completion/git-completion.bash"
      bash_completion.install "contrib/completion/git-prompt.sh"

      zsh_completion.install "contrib/completion/git-completion.zsh" => "_git"
      cp "#{bash_completion}/git-completion.bash", zsh_completion
    end

    (share+"git-core").install "contrib"

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    man.install resource("man")
    (share+"doc/git-doc").install resource("html")

    # Make html docs world-readable
    chmod 0644, Dir["#{share}/doc/git-doc/**/*.{html,txt}"]
    chmod 0755, Dir["#{share}/doc/git-doc/{RelNotes,howto,technical}"]

    # To avoid this feature hooking into the system OpenSSL, remove it.
    # If you need it, install git --with-brewed-openssl.
  end

  def caveats; <<-EOS.undent
    The OS X keychain credential helper has been installed to:
      #{HOMEBREW_PREFIX}/bin/git-credential-osxkeychain

    The "contrib" directory has been installed to:
      #{HOMEBREW_PREFIX}/share/git-core/contrib
    EOS
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      assert_equal "bin/brew", `#{bin}/git ls-files -- bin`.strip
    end
  end
end

__END__
diff --git a/Documentation/config.txt b/Documentation/config.txt
index 43bb53c..4b109a5 100644
--- a/Documentation/config.txt
+++ b/Documentation/config.txt
@@ -1594,16 +1594,29 @@ http.sslVerify::
 	over HTTPS. Can be overridden by the 'GIT_SSL_NO_VERIFY' environment
 	variable.
 
+http.sslEngine::
+	String specifying the SSL engine to be used by curl.  This can be used to
+	specify non-default or dynamically loaded engines.  Can be overridden by
+	the 'GIT_SSL_ENGINE' environment variable.
+
 http.sslCert::
 	File containing the SSL certificate when fetching or pushing
 	over HTTPS. Can be overridden by the 'GIT_SSL_CERT' environment
 	variable.
 
+http.sslCertType::
+	Specifies the format of the certificate to curl as one of (PEM|DER|ENG).
+	Can be overridden by the 'GIT_SSL_CERTTYPE' environment variable.
+
 http.sslKey::
 	File containing the SSL private key when fetching or pushing
 	over HTTPS. Can be overridden by the 'GIT_SSL_KEY' environment
 	variable.
 
+http.sslKeyType::
+	Specifies the format of the private key to curl as one of (PEM|DER|ENG).
+	Can be overridden by the 'GIT_SSL_KEYTYPE' environment variable.
+
 http.sslCertPasswordProtected::
 	Enable Git's password prompt for the SSL certificate.  Otherwise
 	OpenSSL will prompt the user, possibly many times, if the
diff --git a/http.c b/http.c
index e9c6fdd..6e4fc73 100644
--- a/http.c
+++ b/http.c
@@ -54,6 +54,10 @@ struct credential http_auth = CREDENTIAL_INIT;
 static int http_proactive_auth;
 static const char *user_agent;
 
+static const char *ssl_keytype;
+static const char *ssl_certtype;
+static const char *ssl_engine;
+
 #if LIBCURL_VERSION_NUM >= 0x071700
 /* Use CURLOPT_KEYPASSWD as is */
 #elif LIBCURL_VERSION_NUM >= 0x070903
@@ -85,6 +89,7 @@ size_t fread_buffer(char *ptr, size_t eltsize, size_t nmemb, void *buffer_)
 	memcpy(ptr, buffer->buf.buf + buffer->posn, size);
 	buffer->posn += size;
 
+
 	return size;
 }
 
@@ -257,6 +262,17 @@ static int http_options(const char *var, const char *value, void *cb)
 	if (!strcmp("http.useragent", var))
 		return git_config_string(&user_agent, var, value);
 
+	/* Adding parsing for curl options relating to engines and */
+	/* key/cert types.  This is necessary if attempting to     */
+	/* specify an external engine (e.g. for smartcards.)       */
+
+	if (!strcmp("http.sslkeytype", var))
+		return git_config_string(&ssl_keytype, var, value);
+	if (!strcmp("http.sslcerttype", var))
+		return git_config_string(&ssl_certtype, var, value);
+	if (!strcmp("http.sslengine", var))
+		return git_config_string(&ssl_engine, var, value);
+
 	/* Fall back on the default ones */
 	return git_default_config(var, value, cb);
 }
@@ -421,6 +437,22 @@ static CURL *get_curl_handle(void)
 	curl_easy_setopt(result, CURLOPT_PROXYAUTH, CURLAUTH_ANY);
 #endif
 
+	/* Adding setting of engine-related curl SSL options. */
+	if (ssl_engine != NULL) {
+		curl_easy_setopt(result, CURLOPT_SSLENGINE, ssl_engine);
+
+		/* Within the lifetime of a single git execution, setting
+		 * the default does nothing interesting.  When curl properly
+		 * duplicates handles, the engine choice will propagate.
+		 */
+		/* curl_easy_setopt(result, CURLOPT_SSLENGINE_DEFAULT, 1L); */
+	}
+
+	if (ssl_keytype != NULL)
+		curl_easy_setopt(result, CURLOPT_SSLKEYTYPE, ssl_keytype);
+	if (ssl_certtype != NULL)
+		curl_easy_setopt(result, CURLOPT_SSLCERTTYPE, ssl_certtype);
+
 	set_curl_keepalive(result);
 
 	return result;
@@ -516,6 +548,11 @@ void http_init(struct remote *remote, const char *url, int proactive_auth)
 			ssl_cert_password_required = 1;
 	}
 
+	/* Added environment variables for expanded engine-related options. */
+	set_from_env(&ssl_keytype, "GIT_SSL_KEYTYPE");
+	set_from_env(&ssl_certtype, "GIT_SSL_CERTTYPE");
+	set_from_env(&ssl_engine, "GIT_SSL_ENGINE");
+
 #ifndef NO_CURL_EASY_DUPHANDLE
 	curl_default = get_curl_handle();
 #endif
