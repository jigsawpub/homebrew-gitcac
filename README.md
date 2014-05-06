Mac OS X gitcac tap
===================

Quickstart
----------

    [ -e /usr/local/bin/brew ] || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew tap jigsawpub/gitcac
    brew install gitcac
    exec bash -l

The first step will install homebrew, which will attempt to install XCode
command-line tools if they're not already installed.

The gitcac installer will prompt you for your password a couple of times to run
privileged actions. This is necessary to install XCode, CACKey, and alter the system
$PATH.

Prerequisites
-------------

This installer will probably only work on Mavericks right now. Feel free to submit a pull request!

Caveats
-------

`curl` and `git` from homebrew might conflict. If you run into problems, try removing them first:

    brew rm curl
    brew rm git

Updates
-------

To receive updates to gitcac, use:

    brew update
    brew upgrade

If you only want to update gitcac and nothing else:

    brew upgrade /usr/local/Library/Taps/jigsawpub/gitcac/*.rb

or

    brew upgrade cackey gitcac{-curl,-git,}

Troubleshooting
---------------

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

Next, verify that OpenSSL is configured correctly:

    $ openssl engine
    (dynamic) Dynamic engine loading support
    (pkcs11) pkcs11 engine

If not, edit `/System/Library/OpenSSL/openssl.cnf` and verify you have a
section like this, or create it if not:

    openssl_conf            = openssl_def

    [openssl_def]
    engines = engine_section

    [engine_section]
    pkcs11 = pkcs11_section

    [pkcs11_section]
    engine_id = pkcs11
    dynamic_path = /usr/local/lib/engines/engine_pkcs11.so
    MODULE_PATH = /usr/lib/pkcs11/cackey.dylib
    init = 1

Then, verify curl loads engines appropriately:

    $ curl --engine list
    Build-time engines:
      dynamic
      pkcs11

If not, try reinstalling `gitcac-curl`:

    brew uninstall curl      # Keep running this until you're out of curl installations
    brew uninstall gitcac-curl
    brew install gitcac-curl

Finally, verify your `~/.gitconfig` file has a section like this, or create one
if it doesn't:

    [http "https://example.com/"]
        sslengine = pkcs11
        sslkeytype = ENG
        sslcerttype = ENG

The URL should be the URL to your git server. This is to prevent git from
asking for a PIN when it shouldn't (like during `npm` installs).