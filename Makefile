all: | /usr/local/bin/git /System/Library/OpenSSL/certs/dod_ca_chain.pem
	git config --global http.sslengine pkcs11
	git config --global http.sslkeytype ENG
	git config --global http.sslcerttype ENG
	@grep -q pkcs11 /System/Library/OpenSSL/openssl.cnf || \
		echo Installing OpenSSL configuration. This may require your password to execute the following command: >&2 ; \
		echo cp openssl.cnf /System/Library/OpenSSL/openssl.cnf >&2 ; \
		sudo cp openssl.cnf /System/Library/OpenSSL/openssl.cnf

/System/Library/OpenSSL/certs/dod_ca_chain.pem:
	@echo Installing DoD CA chain. This may require your password to execute the following command: >&2
	@echo cp dod_ca_chain.pem >&2 $@
	sudo cp dod_ca_chain.pem $@