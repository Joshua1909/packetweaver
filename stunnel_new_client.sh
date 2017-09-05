#!/bin/bash
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 -subj "/C=AU/ST=sydney/L=packetweaver/O=packetweaver.com/OU=IT/CN=commonname/emailAddress=admin@packetweaver.com"
sudo sh -c "cat key.pem cert.pem >> /etc/stunnel/stunnel.pem"
