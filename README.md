# CentOS Apache ModSecurity WAF

This is the CentOS Apache ModSecurity with the OWASP ModSecurity Core Rule Set based Puzzle WAF.  
The main purpose of this WAF is to be loaded into OpenShift projects.

## Environment Variables

Commonly used environment variables are:  

| Name     | Description|
| -------- | ------------------------------------------------------------------- |
| `PARANOIA` | An integer indicating the paranoia level between 1 and 4 (Default: 1)               |
| `EXECUTING_PARANOIA` | An integer indicating the executing_paranoia_level (Must be equal or higher than PARANOIA) |
| `ANOMALY_INBOUND` | An integer indicating the inbound_anomaly_score_threshold (Default: 5) |
| `ANOMALY_OUTBOUND` | An integer indicating the outbound_anomaly_score_threshold (Default: 4) |
| `PORT` | An integer indicating the listening port of the Apache RP (Default: 8443)               |
| `SERVER_NAME` | A string indicating the Apache ServerName (Default: localhost) |
| `BACKEND` | The IP Address or Name or OpenShift Servicename (and optional port) of the to be protected backend server. (Default: http://localhost:8080) |

For a full list of available environment variables see [Dockerfile](Dockerfile).  
For an explanation of environment variables see [Links](#links).

## Image quay.io

https://quay.io/repository/puzzleitc/centos-apache-modsecurity

`docker pull quay.io/puzzleitc/centos-apache-modsecurity:crs-v3.3.0-waf2`

The image build is triggered by a GitHub push.

## WAF in OpenShift

To add the WAF to an OpenShift project see [OpenShift README](openshift/README.md).

## TLS Server Certificate and Key

The WAF only listens on HTTPS. No plain HTTP is available.  
A self signed TLS certificate and a key is added to the default image. They must be overwritten by a valid certificate and key!

Example (local docker run):  
`docker run -v $(pwd)/ssl-cert.pem:/etc/ssl/certs/ssl-cert.pem -v $(pwd)/ssl-cert.key:/etc/ssl/private/ssl-cert.key ...`

## Custom Error Pages

Custom Error Pages for HTTP statuses 400, 403, 404, 500, 502, 503 can be mounted into the image.

Example (local docker run) for 503.html:  
`docker run -v $(pwd)/503.html:/var/www/html/error/503.html ...`

## Overriding or Adding Apache Directives

Most of the Apache directives can be set with environment variables. However, if a particular Apache directive can not be set through an env variable, there is an option to set is as follows:
* server.conf -> server context
* virtualhost.conf -> virtualhost context
* proxy.conf -> proxy context

Example server.conf file:

```
$ cat server.conf
SSLProtocol             All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
```

Example (local docker run) for overriding an Apache directive in the server context:

`docker run -v $(pwd)/server.conf:/etc/httpd/conf/server.conf ...`

Please consider adding an env variable to the Dockerfile, as this can make the configuration more difficult to maintain.

## Logging

The Apache `access.log` and `error.log` are written to Standard Out.  
The ModSecurity Audit Logging is set to serial and JSON. This log is written to standard out too.  
All these settings can be configured during startup.

## ModSecurity Tuning

An iterative tuning process is recommended.
* Start the pod with a high value of 200 for ANOMALY_INBOUND and ANOMALY_OUTBOUND
* Test the application and follow an iterative tuning process as described in: https://www.netnea.com/cms/apache-tutorial-8-modsecurity-core-rules-tunen/
* Set an ANOMALY_INBOUND of 5 and ANOMALY_OUTBOUND of 4 to set the WAF to blocking.

Only if these thresholds are lowered in the last step, the WAF is set to blocking.

### Service Specific Tuning

Service specific rules can be loaded into the container:  
Rules before CRS: `/etc/httpd/modsecurity/service/custom-before-crs`  
Rules after CRS: `/etc/httpd/modsecurity/service/custom-after-crs`  

### Rule ID Range

We follow Christian Folini (netnea) best practices: 

```
# == ModSec Rule ID Namespace Definition
# Service-specific before Core-Rules:    10000 -  49999
#  - Puzzle Standard Exclusions          10000 -  19999
#  - Service Specific Exclusions         20000 -  49999
# Service-specific after Core-Rules:     50000 -  79999
# Locally shared rules:                  80000 -  99999
#  - Performance:                        90000 -  90199
# Recommended ModSec Rules (few):       200000 - 200010
# OWASP Core-Rules:                     900000 - 999999
```

Important for us (Puzzle) are:

* Puzzle Standard Exclusions before CRS (ids: 10000 - 19999)
* Service Specific Exclusions before CRS (ids: 20000 - 49999)

## Test the container locally

`docker run -dti -e PARANOIA=2 -e EXECUTING_PARANOIA=2 -e BACKEND='https://myserver:8443' -e SERVERNAME='myserver.puzzle.ch' -p 8443:8443 quay.io/puzzleitc/centos-apache-modsecurity:crs-v3.3.0-waf2`

For convenience, a [docker-compose](./docker-compose.yaml) file with preconfigured volumes and environment variables is available.

## Making changes

Development is done in a branch created from the newest tag. Current development branch is: crs-v3.3.0-waf2-dev.

* Please base your changes on the latest development branch. 
* Create a topic branch for your feature or bug fix.

### Releasing

When a development cycle is done, we release by tagging the current development branch: crs-v3.3.0-waf2.

When a development cycle is finished:
* A tag is created. Example: crs-v3.3.0-waf2 (without -dev at the end)
* The latest development branch is merged into master. Example: crs-v3.3.0-waf2-dev
* The current development branch is deleted. Example: crs-v3.3.0-waf2-dev
* And a new development branch will be created. Example: crs-v3.3.0-waf3-dev

## Links

* [Official ModSecurity v2.x Reference Manual](https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-(v2.x)) for ModSecurity variables explanation
* [Core Rule Set Variables](https://github.com/coreruleset/coreruleset/blob/v3.3.0/crs-setup.conf.example) for OWASP Core Rule Set variables explanation
