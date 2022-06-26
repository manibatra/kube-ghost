## Ingress-Nginx

Install using 

```bash
helm upgrade --install --namespace ingress-nginx --repo https://kubernetes.github.io/ingress-nginx ingress-nginx ingress-nginx --create-namespace
```