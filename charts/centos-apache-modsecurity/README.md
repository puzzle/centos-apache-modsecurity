# Helm Cart for WAF Deployment with Apache and ModSecurity CRS

## Preconditions:

### Config Map for ModSecurity CRS Tuning rules
`kubectl create configmap custom-rules --from-file=custom-before-crs-rules.conf=openshift/custom-before-crs-rules.conf --from-file=custom-after-crs-rules.conf=openshift/custom-after-crs-rules.conf`

### Secret for waf-cert-secret
There is a default selfsigned certificate that can be used for the Apache. 
`kubectl create secret tls waf-cert-secret --key localhost.key --cert localhost.pem`

But you can (should) use your own. e.g. create one using [Cert Manager](https://cert-manager.io/docs/) or any other methods and store in the `waf-cert-secret` Kubernetes Secret.

## Add the WAF to an Kubernetes Namespace

Check `values.yaml` for all available configuration values.

`helm install -f values.yaml --set modsecurity.backend=https://mybackend:8443 ./charts/centos-apache-modsecurity`

If a ingress already exists, this route can now be switched to the service of the WAF.

**Example:**

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  name: myingress
spec:
  rules:
  - host: mywafsecuredhostname.com
    http:
      paths:
      - backend:
          serviceName: waf-service-centos-apache-modsecurity
          servicePort: 8443
  tls:
  - hosts:
    - mywafsecuredhostname.com
```