Mac OS X gitcac tap
===================

Quickstart
----------

    [ -e /usr/local/bin/brew ] || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    # Don't worry, these will all be reinstalled
    brew uninstall --force git curl engine_pkcs11 libp11 gitcac-git gitcac-curl gitcac openssl
    brew tap jigsawpub/gitcac
    brew update
    brew install gitcac
    exec bash -l

The first step will install homebrew, which will attempt to install XCode
command-line tools if they're not already installed.

The gitcac installer will prompt you for your password a couple of times to run
privileged actions. This is necessary to install XCode, CACKey, and alter the
system $PATH.

Updates
-------

To receive updates to gitcac, use:

    brew update
    brew upgrade

If you only want to update gitcac and nothing else:

    brew upgrade /usr/local/Library/Taps/jigsawpub/gitcac/*.rb

Troubleshooting
---------------

Before anything else, try running the quickstart commands again.

If the problem is not resolved, read each of these sections in order. Each one
contains a command and its expected output; if your expected output doesn't
match, follow the instructions in that section to resolve the issue.

### Brew issue

See if Homebrew detects any serious issues:

    $ brew doctor
    Your system is ready to brew.

If not, follow the advice given or reinstall Homebrew.

### Path issues

First, verify that the proper `git` and `curl` are on your PATH:

    $ which git
    /usr/local/bin/git
    $ which curl
    /usr/local/bin/curl

If `/usr/local/bin/curl` and `/usr/local/bin/git` don't exist, reinstall them
with `brew install gitcac-curl gitcac-git`.

If `/usr/local/bin/curl` and `/usr/local/bin/git` exist but aren't being
detected by `which`, modify /etc/paths and promote `/usr/local/bin` to the top
of the file.

### OpenSSL configuration

Next, verify that OpenSSL is configured correctly:

    $ /usr/local/opt/openssl/bin/openssl engine
    (dynamic) Dynamic engine loading support
    (pkcs11) pkcs11 engine

If `/usr/local/opt/openssl/bin/openssl` does not exist, try installing it:

    brew install openssl

If it exists but doesn't print out the `pkcs11` line, ensure that
`$OPENSSL_CONF` is set:

    $ echo $OPENSSL_CONF
    /usr/local/etc/gitcac-openssl.cnf

If the file `/usr/local/etc/gitcac-openssl.cnf` is missing or has invalid
contents, uninstall and reinstall `gitcac`.

If the file is correct, ensure that `/usr/lib/pkcs11/cackey.dylib` is present
and executable by your current user.

If you get a segmentation fault (11), uninstall and reinstall both
`engine_pkcs11` and `libp11`.

### curl configuration

Then, verify curl loads engines appropriately:

    $ curl --engine list
    Build-time engines:
      dynamic
      pkcs11

If not, try reinstalling `gitcac-curl`:

    brew uninstall --force curl gitcac-curl
    brew install gitcac-curl

### git configuration

Finally, verify your `~/.gitconfig` file has a section like this, or create one
if it doesn't:

    [http "https://example.com/"]
        sslengine = pkcs11
        sslkeytype = ENG
        sslcerttype = ENG

The URL should be the URL to your git server. This is to prevent git from
asking for a PIN when it shouldn't (like during `npm` installs).