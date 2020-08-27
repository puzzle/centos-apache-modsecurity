# OpenShift WAF Deployment

## Preconditions

The OpenShift template requires a configmap named custom-rules.

### Config Map for ModSecurity CRS Tuning rules

To add custom ModSecurity tuning rules to a WAF, either create a configmap manually:

`oc create configmap custom-rules --from-file=custom-before-crs-rules.conf=openshift/custom-before-crs-rules.conf --from-file=custom-after-crs-rules.conf=openshift/custom-after-crs-rules.conf`

Or you add the configmap as a yaml file:

```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: custom-rules
  labels:
    app: centos-apache-modsecurity
data:
  custom-before-crs-rules.conf: |
    # See https://github.com/puzzle/centos-apache-modsecurity/blob/master/openshift/custom-before-crs-rules.conf
  custom-after-crs-rules.conf: |
    # See https://github.com/puzzle/centos-apache-modsecurity/blob/master/openshift/custom-after-crs-rules.conf
```

It's best practice to add customized ModSecurity tuning rules to the application repository.

### Config Map for Custom Error Pages

To add custom error pages to your WAF, create a configmap.

```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: error-documents
  labels:
    app: centos-apache-modsecurity
data:
  400.html: |
   <!DOCTYPE html><html><head><title>Error</title></head><body><h1>Custom Error Message</h1></body></html>
  403.html: |
   <!DOCTYPE html><html><head><title>Error</title></head><body><h1>Custom Error Message</h1></body></html>
  404.html: |
   <!DOCTYPE html><html><head><title>Error</title></head><body><h1>Custom Error Message</h1></body></html>
  500.html: |
   <!DOCTYPE html><html><head><title>Error</title></head><body><h1>Custom Error Message</h1></body></html>
  502.html: |
   <!DOCTYPE html><html><head><title>Error</title></head><body><h1>Custom Error Message</h1></body></html>
  503.html: |
   <!DOCTYPE html><html><head><title>Error</title></head><body><h1>Custom Error Message</h1></body></html>
```

### Config Map for overriding or adding Apache Directives

Please see the [main README](../README.md) for further information.

To add or override an Apache directive, create a configmap.

```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: apache-directives
  labels:
    app: centos-apache-modsecurity
data:
  server.conf: |
   SSLProtocol             All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
```

## Add the WAF to an OpenShift project

The following command adds a WAF to your project:

`oc process -f openshift/centos-apache-modsecurity-template.yaml -p BACKEND=https://mybackend:8443 | oc apply -f -`

If a route already exists, this route can now be switched to the service of the WAF.  
If a new route needs to be created, the [waf-route-example.yaml](./waf-route-example.yaml) can be used.
Be sure to add a valid certificate/key pair, unless the OpenShift router has a suitable default certificate
installed which already covers your route.

## TLS Certificate and Key

The template also takes care of creating a TLS certificate/key pair for the WAF, required
for the HTTPS connections between the OpenShift routers and the WAF.

We do this by adding the annotation to the service:  
`service.alpha.openshift.io/serving-cert-secret-name: waf-cert-secret`

This certificate/key pair is mounted into the WAF pod and renewed automatically by OpenShift.
