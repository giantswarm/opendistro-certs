#!/bin/bash

#RootCA
kubectl get secret ${SECRET_NAME:-"opendistro"}-rootca-certs -n ${NAMESPACE:-"opendistro"} > std 2>&1
if [ $? -eq 1 ]; then
    echo "Creating root CA"
    certstrap init --common-name "rootCA" --expires ${EXPIRATION:-"5 years"} --organization ${ORGANIZATION:-"Giant Swarm"} --passphrase ""

    kubectl create secret generic ${SECRET_NAME:-"opendistro"}-rootca-certs -n ${NAMESPACE:-"opendistro"} \
        --from-file=rootCA.crl=./out/rootCA.crl \
        --from-file=rootCA.crt=./out/rootCA.crt \
        --from-file=rootCA.key=./out/rootCA.key
else
    echo "RootCA already exists"
    mkdir out
    kubectl get secrets ${SECRET_NAME:-"opendistro"}-rootca-certs -o jsonpath="{.data.rootCA\.crl}" | base64 --decode > ./out/rootCA.crl
    kubectl get secrets ${SECRET_NAME:-"opendistro"}-rootca-certs -o jsonpath="{.data.rootCA\.crt}" | base64 --decode > ./out/rootCA.crt
    kubectl get secrets ${SECRET_NAME:-"opendistro"}-rootca-certs -o jsonpath="{.data.rootCA\.key}" | base64 --decode > ./out/rootCA.key
fi



#Transport Certs
kubectl get secret ${SECRET_NAME:-"opendistro"}-transport-certs -n ${NAMESPACE:-"opendistro"} > std 2>&1
if [ $? -eq 1 ]; then
    echo "Creating transport certificates"
    certstrap request-cert --common-name "transport" --organization ${ORGANIZATION:-"Giant Swarm"} --passphrase ""
    certstrap sign transport --CA "rootCA" --expires ${EXPIRATION:-"5 years"}
    openssl pkcs8 -v1 "PBE-SHA1-3DES" -in ./out/transport.key -topk8 -out ./out/transport.pem -nocrypt

    kubectl create secret generic ${SECRET_NAME:-"opendistro"}-transport-certs -n ${NAMESPACE:-"opendistro"} \
        --from-file=elk-transport-crt.pem=./out/transport.crt \
        --from-file=elk-transport-key.pem=./out/transport.pem \
        --from-file=elk-transport-root-ca.pem=./out/rootCA.crt

    echo "Deleting pods with label ${RELEASE:-"opendistro"}"
    kubectl delete pods -l release=${RELEASE:-"opendistro"}
else
    echo "Transport certificates already exist"
fi

exit $?