# OpenShift WAF Deployment

## Preconditions:

### Config Map for ModSecurity CRS Tuning rules
`oc create configmap custom-rules --from-file=custom-before-crs-rules.conf=openshift/custom-before-crs-rules.conf --from-file=custom-after-crs-rules.conf=openshift/custom-after-crs-rules.conf`

## Add the WAF to an OpenShift project
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
