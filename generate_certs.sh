#!/bin/bash

#RootCA
certstrap init --common-name "rootCA" --expires ${EXPIRATION:-"5 years"} --organization ${ORGANIZATION:-"Giant Swarm"} --passphrase ""

kubectl create secret generic ${SECRET_NAME:-"opendistro"}-rootca-certs -n ${NAMESPACE:-"opendistro"} \
      --from-file=rootCA.crl=./out/rootCA.crl \
      --from-file=rootCA.crt=./out/rootCA.crt \
      --from-file=rootCA.key=./out/rootCA.key

#Transport Certs
certstrap request-cert --common-name "transport" --passphrase "" 
certstrap sign transport --CA "rootCA" --expires ${EXPIRATION:-"5 years"}
openssl pkcs8 -v1 "PBE-SHA1-3DES" -in ./out/transport.key -topk8 -out ./out/transport.pem -nocrypt

kubectl create secret generic ${SECRET_NAME:-"opendistro"}-transport-certs -n ${NAMESPACE:-"opendistro"} \
      --from-file=elk-transport-crt.pem=./out/transport.crt \
      --from-file=elk-transport-key.pem=./out/transport.pem \
      --from-file=elk-transport-root-ca.pem=./out/rootCA.crt