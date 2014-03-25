Mac OS X gitcac tap
===================

Quickstart
----------

    [ -e /usr/local/bin/brew ] || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew tap dustinparker/gitcac
    brew install gitcac
    brew pin curl git
    exec bash -l

The installer will prompt you for your password a couple of times to run
privileged actions. This is necessary to install CACKey and alter the system
$PATH.