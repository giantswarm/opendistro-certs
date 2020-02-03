# Generate certificates for opendistro-app
[![CircleCI](https://circleci.com/gh/giantswarm/opendistro-certs.svg?style=shield)](https://circleci.com/gh/giantswarm/opendistro-certs)
[![Docker Repository on Quay](https://quay.io/repository/giantswarm/opendistro-certs/status "Docker Repository on Quay")](https://quay.io/repository/giantswarm/opendistro-certs)

Generates certificates based on [certstrap](https://github.com/square/certstrap) and store them in kubernetes secrets

# Variables
EXPIRATION - Expiration for certificates (5 years, 2 months, 1 day)
ORGANIZATION - Organization set in certificate
SECRET_NAME - Secret name prefix that will contain the certificates
NAMESPACE - Namespace where certificates will be stores