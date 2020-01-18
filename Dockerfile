FROM centos:7

ARG BRANCH=tags/v3.2.0
ARG REPO=SpiderLabs/owasp-modsecurity-crs
ENV PARANOIA=1 \
    PORT=8443 \
    EXECUTING_PARANOIA=1 \
    ANOMALY_INBOUND=5 \
    ANOMALY_OUTBOUND=4 \
    SERVER_NAME=localhost \
    BACKEND=http://localhost:8080 \
    APACHE_TIMEOUT=10 \
    APACHE_MAX_REQUEST_WORKERS=100 \
    APACHE_LOGLEVEL=notice \
    APACHE_ERRORLOG='/dev/stdout' \
    APACHE_ACCESSLOG='/dev/stdout extended' \
    APACHE_PERFLOG='/var/log/httpd/modsec-perf.log perflog env=write_perflog' \
    SECRULEENGINE=On \
    REQ_BODY_ACCESS=On \
    REQ_BODY_LIMIT=10000000 \
    REQ_BODY_NOFILES_LIMIT=64000 \
    RESP_BODY_ACCESS=On \
    RESP_BODY_LIMIT=10000000 \
    PCRE_MATCH_LIMIT=100000 \
    PCRE_MATCH_LIMIT_RECURSION=100000 \
    MODSEC_DEBUG_LOG=/var/log/modsecurity/modsec_debug.log \
    MODSEC_DEBUG_LOGLEVEL=0 \
    MODSEC_AUDIT_LOG=/var/log/modsecurity/audit.log \
    MODSEC_AUDIT_LOGPARTS=ABEFHIJKZ \
    MODSEC_AUDIT_LOGTYPE=concurrent \
    MODSEC_AUDIT_LOGFORMAT=JSON \
    MODSEC_AUDIT_STORAGE=/var/log/modsecurity/audit/ \
    MODSEC_DATA_DIR=/tmp/ \
    MODSEC_TMP_DIR=/tmp/ \
    MODSEC_UPLOAD_DIR=/tmp/ \
    MODSEC_ENFORCE_BODYPROC_URLENCODED=1 \
    MODSEC_ALLOWED_METHODS='GET HEAD POST OPTIONS' \
    MODSEC_ALLOWED_REQUEST_CONTENT_TYPE='application/x-www-form-urlencoded|multipart/form-data|text/xml|application/xml|application/soap+xml|application/x-amf|application/json|application/octet-stream|application/csp-report|application/xss-auditor-report|text/plain' \
    MODSEC_ALLOWED_HTTP_VERSIONS='HTTP/1.0 HTTP/1.1 HTTP/2 HTTP/2.0' \
    MODSEC_RESTRICTED_EXTENSIONS='.asa/ .asax/ .ascx/ .axd/ .backup/ .bak/ .bat/ .cdx/ .cer/ .cfg/ .cmd/ .com/ .config/ .conf/ .cs/ .csproj/ .csr/ .dat/ .db/ .dbf/ .dll/ .dos/ .htr/ .htw/ .ida/ .idc/ .idq/ .inc/ .ini/ .key/ .licx/ .lnk/ .log/ .mdb/ .old/ .pass/ .pdb/ .pol/ .printer/ .pwd/ .resources/ .resx/ .sql/ .sys/ .vb/ .vbs/ .vbproj/ .vsdisco/ .webinfo/ .xsd/ .xsx/' \
    MODSEC_RESTRICTED_HEADERS='/proxy/ /lock-token/ /content-range/ /translate/ /if/' \
    MODSEC_STATIC_EXTENSIONS='/.jpg/ /.jpeg/ /.png/ /.gif/ /.js/ /.css/ /.ico/ /.svg/ /.webp/' \
    MODSEC_ALLOWED_REQUEST_CONTENT_TYPE_CHARSET='utf-8|iso-8859-1|iso-8859-15|windows-1252' \
    MODSEC_ARG_NAME_LENGTH=256 \
    MODSEC_MAX_NUM_ARGS=300 \
    MODSEC_ARG_LENGTH=400 \
    MODSEC_TOTAL_ARG_LENGTH=64000 \
    MODSEC_MAX_FILE_SIZE=100000000 \
    MODSEC_COMBINED_FILE_SIZES=100000000 \
    PROXY_TIMEOUT=30
# MODSEC_AUDIT_LOGFORMAT is currently not supported

#FIXME: kein git
RUN yum install -y httpd mod_security mod_ssl wget curl git && \
    yum -y update && \
    yum clean all

RUN mkdir -p /var/log/modsecurity/audit \
    /etc/httpd/modsecurity/puzzle/custom-before-crs /etc/httpd/modsecurity/service/custom-before-crs \
    /etc/httpd/modsecurity/puzzle/custom-after-crs /etc/httpd/modsecurity/service/custom-after-crs

RUN cd /opt && \
    git clone https://github.com/${REPO}.git owasp-crs && \
    cd owasp-crs && \
    git checkout -qf ${BRANCH} && \
    cp -R /opt/owasp-crs/ /etc/httpd/modsecurity/owasp-crs/ && \
    chmod -R g=u /var/log/modsecurity/ /var/log/httpd/ && \
    chown apache:root -R /var/log/modsecurity/ /var/log/httpd/ && \
    rm -rf /etc/httpd/modsecurity.d/

COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY crs-setup-customizable.conf /etc/httpd/modsecurity/owasp-crs/crs-setup-customizable.conf
COPY localhost.key /etc/ssl/private/ssl-cert.key
COPY localhost.pem /etc/ssl/certs/ssl-cert.pem

EXPOSE 8443

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

USER apache
