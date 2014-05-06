require 'formula'

class GitcacGit < Formula
  homepage 'http://git-scm.com'
  url "https://www.kernel.org/pub/software/scm/git/git-1.9.1.tar.gz"
  sha1 "804453dba489cae0d0f0402888b77e1aaa40bae8"
  head "https://github.com/git/git.git", :shallow => false

  bottle do
    root_url "https://raw.github.com/dustinparker/homebrew-gitcac-binaries/master"
    sha1 "c7f135a0c340de076df54a74e2dc71e839d7ff71" => :mavericks
  end

  option 'with-blk-sha1', 'Compile with the block-optimized SHA1 implementation'
  option 'without-completions', 'Disable bash/zsh completions from "contrib" directory'
  option 'with-persistent-https', 'Build git-remote-persistent-https from "contrib" directory'

  depends_on 'pcre' => :optional
  depends_on 'gettext' => :optional
  depends_on 'gitcac-curl'
  depends_on 'go' => :build if build.with? 'persistent-https'

  resource "man" do
    url "https://www.kernel.org/pub/software/scm/git/git-manpages-1.9.1.tar.gz"
    sha1 "d8cef92bc11696009b64fb6d4936eaa8d7759e7a"
  end

  resource "html" do
    url "https://www.kernel.org/pub/software/scm/git/git-htmldocs-1.9.1.tar.gz"
    sha1 "68aa0c7749aa918e5e98eecd84e0538150613acd"
  end

  stable do
      patch :DATA
  end

  def install
    # If these things are installed, tell Git build system to not use them
    ENV['NO_FINK'] = '1'
    ENV['NO_DARWIN_PORTS'] = '1'
    ENV['V'] = '1' # build verbosely
    ENV['NO_R_TO_GCC_LINKER'] = '1' # pass arguments to LD correctly
    ENV['PYTHON_PATH'] = which 'python'
    ENV['PERL_PATH'] = which 'perl'

    if MacOS.version >= :mavericks and MacOS.dev_tools_prefix
      ENV['PERLLIB_EXTRA'] = "#{MacOS.dev_tools_prefix}/Library/Perl/5.16/darwin-thread-multi-2level"
    end

    unless quiet_system ENV['PERL_PATH'], '-e', 'use ExtUtils::MakeMaker'
      ENV['NO_PERL_MAKEMAKER'] = '1'
    end

    ENV['BLK_SHA1'] = '1' if build.with? 'blk-sha1'

    if build.with? 'pcre'
      ENV['USE_LIBPCRE'] = '1'
      ENV['LIBPCREDIR'] = Formula.factory('pcre').opt_prefix
    end

    ENV['NO_GETTEXT'] = '1' unless build.with? 'gettext'

    system "make", "prefix=#{prefix}",
                   "sysconfdir=#{etc}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "install"

    bin.install Dir["contrib/remote-helpers/git-remote-{hg,bzr}"]

    # Install the OS X keychain credential helper
    cd 'contrib/credential/osxkeychain' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-credential-osxkeychain'
      system "make", "clean"
    end

    # Install git-subtree
    cd 'contrib/subtree' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-subtree'
    end

    if build.with? 'persistent-https'
      cd 'contrib/persistent-https' do
        system "make"
        bin.install 'git-remote-persistent-http',
                    'git-remote-persistent-https',
                    'git-remote-persistent-https--proxy'
      end
    end

    unless build.without? 'completions'
      # install the completion script first because it is inside 'contrib'
      bash_completion.install 'contrib/completion/git-completion.bash'
      bash_completion.install 'contrib/completion/git-prompt.sh'

      zsh_completion.install 'contrib/completion/git-completion.zsh' => '_git'
      cp "#{bash_completion}/git-completion.bash", zsh_completion
    end

    (share+'git-core').install 'contrib'

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    man.install resource('man')
    (share+'doc/git-doc').install resource('html')

    # Make html docs world-readable; check if this is still needed at 1.8.6
    chmod 0644, Dir["#{share}/doc/git-doc/**/*.{html,txt}"]
  end

  def caveats; <<-EOS.undent
    The OS X keychain credential helper has been installed to:
      #{HOMEBREW_PREFIX}/bin/git-credential-osxkeychain

    The 'contrib' directory has been installed to:
      #{HOMEBREW_PREFIX}/share/git-core/contrib
    EOS
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      assert_equal 'bin/brew', `#{bin}/git ls-files -- bin`.strip
    end
  end
end

__END__
diff --git a/Documentation/config.txt b/Documentation/config.txt
index 5f4d793..c63054b 100644
--- a/Documentation/config.txt
+++ b/Documentation/config.txt
@@ -1468,16 +1468,29 @@ http.sslVerify::
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
index 70eaa26..779fd6f 100644
--- a/http.c
+++ b/http.c
@@ -51,6 +51,10 @@ struct credential http_auth = CREDENTIAL_INIT;
 static int http_proactive_auth;
 static const char *user_agent;
 
+static const char *ssl_keytype;
+static const char *ssl_certtype;
+static const char *ssl_engine;
+
 #if LIBCURL_VERSION_NUM >= 0x071700
 /* Use CURLOPT_KEYPASSWD as is */
 #elif LIBCURL_VERSION_NUM >= 0x070903
@@ -77,6 +81,7 @@ size_t fread_buffer(char *ptr, size_t eltsize, size_t nmemb, void *buffer_)
 	memcpy(ptr, buffer->buf.buf + buffer->posn, size);
 	buffer->posn += size;
 
+
 	return size;
 }
 
@@ -216,6 +221,17 @@ static int http_options(const char *var, const char *value, void *cb)
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
@@ -368,6 +384,22 @@ static CURL *get_curl_handle(void)
 		curl_easy_setopt(result, CURLOPT_PROXYAUTH, CURLAUTH_ANY);
 	}
 
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
@@ -464,6 +496,11 @@ void http_init(struct remote *remote, const char *url, int proactive_auth)
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
