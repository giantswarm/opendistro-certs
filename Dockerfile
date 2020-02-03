FROM fedora

RUN curl -L https://github.com/square/certstrap/releases/download/v1.2.0/certstrap-1.2.0-linux-amd64 -o /usr/local/bin/certstrap \
    && chmod +x /usr/local/bin/certstrap

RUN curl https://storage.googleapis.com/kubernetes-release/release/v1.16.4/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl


WORKDIR /workspace
RUN chown 1000:1000 .
COPY generate_certs.sh .
RUN chmod +x generate_certs.sh && chown 1000:1000 generate_certs.sh

USER 1000
CMD ./generate_certs.sh