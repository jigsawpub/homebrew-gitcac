all: | /usr/local/bin/git /System/Library/OpenSSL/certs/dod_ca_chain.pem
	git config --global push.default current
	git config --global url."https://".insteadOf git://
	git config --global 'http.https://jigsaw-confluence.ctisl.gtri.gatech.edu/.sslengine' pkcs11
	git config --global 'http.https://jigsaw-confluence.ctisl.gtri.gatech.edu/.sslkeytype' ENG
	git config --global 'http.https://jigsaw-confluence.ctisl.gtri.gatech.edu/.sslcerttype' ENG
	head -n1 /etc/paths|grep -q '^/usr/local/bin$$' || sudo -i 'cp /etc/paths tmppaths && (echo /usr/local/bin; cat tmppaths) > /etc/paths && rm tmppaths'
	@grep -q pkcs11 /System/Library/OpenSSL/openssl.cnf || \
		sudo cp openssl.cnf /System/Library/OpenSSL/openssl.cnf

/System/Library/OpenSSL/certs/dod_ca_chain.pem:
	sudo cp dod_ca_chain.pem $@