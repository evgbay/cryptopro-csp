FROM evgbay/cryptopro-csp-base:1.6.0

ARG LICENSE
ARG CA_ROOT_CERT
ARG CLIENT_PFX_FILE
ARG CLIENT_PFX_PASSWORD
ENV CLIENT_PFX_PASSWORD=${CLIENT_PFX_PASSWORD}
ARG CLIENT_CERT_THUMB

RUN if [ -n "${LICENSE}" ]; then \
    /opt/cprocsp/sbin/amd64/cpconfig -license -set ${LICENSE}; \
    fi &&  \
    /opt/cprocsp/sbin/amd64/cpconfig -license -view

COPY config/certificates/${CA_ROOT_CERT} /tls/certs/
RUN /opt/cprocsp/bin/amd64/certmgr -install -silent -store mROOT -file /tls/certs/${CA_ROOT_CERT}

COPY config/certificates/${CLIENT_PFX_FILE} /var/opt/cprocsp/keys/root/
WORKDIR /var/opt/cprocsp/keys/root/
RUN /opt/cprocsp/bin/amd64/certmgr -install -provtype 80 -pfx  \
    -file ${CLIENT_PFX_FILE} -silent -keep_exportable -pin ${CLIENT_PFX_PASSWORD} &&  \
    /opt/cprocsp/bin/amd64/certmgr -list && \
    mkdir -p /tls/stunnel/ && \
    /opt/cprocsp/bin/amd64/certmgr -export -cert -thumbprint ${CLIENT_CERT_THUMB} -dest /tls/stunnel/tls_client.cer

COPY /config/stunnel.conf /tls/stunnel/

CMD ["/opt/cprocsp/sbin/amd64/stunnel_thread", "/tls/stunnel/stunnel.conf"]