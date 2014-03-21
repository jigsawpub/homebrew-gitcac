PREFIX:=/usr/local
TAP=dustinparker/gitcac

all: | /usr/local/bin/git /System/Library/OpenSSL/certs/dod_ca_chain.pem
	git config --global http.sslengine pkcs11
	git config --global http.sslkeytype ENG
	git config --global http.sslcerttype ENG
	echo Installing OpenSSL configuration. This will require your password to execute the following command:
	sudo cp openssl.cnf /System/Library/OpenSSL/openssl.cnf

/System/Library/OpenSSL/certs/dod_ca_chain.pem:
	echo Installing DoD CA chain. This will require your password to execute the following command:
	sudo cp dod_ca_chain.pem $@

$(PREFIX)/bin/git $(PREFIX)/bin/curl: $(PREFIX)/bin/brew
	brew install gitcac

$(PREFIX)/bin/brew: | 
	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"