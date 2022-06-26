### Kube-Ghost

A minimal configuration for running [Ghost](https://ghost.io/) on Kubernetes/K3s. 

### Setup

In line with keeping the project as lean as possible we will be using [K3s](https://k3s.io/) but most of the underlying concepts can be applied to a Kubernetes cluster as well. 

#### Bootstrapping the cluster

- For the sake of this exercise the cluster was spun on Linode. There may be some edge cases that are not covered here when using a different cloud provider.
- Two nodes were used : 1 master and  1 agent/worker node.

1. Copy the bootstrap.sh script to the node you want to use as the master and run it as follows : 
```bash
$ ./bootstrap.sh master
```

2. Once the master node is ready, copy the bootstrap.sh script to the node you want to use as the agent/worker and run it as follows : 
```bash
$ ./bootstrap.sh agent-1 <node-public-ip> <k3s-token>
```
The k3s token can be found at `/var/lib/rancher/k3s/server/node-token` on the master node.

#### Deploy the [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/)

1. To install using helm run the following command : 
```bash
$ helm upgrade --install --namespace ingress-nginx --repo https://kubernetes.github.io/ingress-nginx ingress-nginx ingress-nginx --create-namespace
```

#### Setup infrastructure for the Ghost application
- Attach a volume to the worker node for Ghost content stored at `/var/lib/ghost/content`.
- Use a managed or self-managed MySQL database. 

For the purpose of this exercise a 20GB Volume and a managed database in Linode were used. 

#### Install [cert-manager](https://cert-manager.io/)
- We will use it to create auto-renewing certificates for the ghost application issued by LetsEncrypt.
```bash
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
```

#### Install the Ghost application. 

1. Fill in the database credentials in `ghost/config.yaml` and `ghost/ghost-secret.txt`.
2. Fill in the API token for your DNS provider (in this case DigitalOcean) in `ghost/do-access-token.txt`. This will be used by the issuer to solve the DNS01 challenge, essentially proving that you control the DNS for the domain you are trying to request a certificate for.
3. Fill in the domains for which you wish to generate the cert in `ghost/cert.yaml`.
4. Deploy :
```bash
$ kubectl apply -k -f ghost/k8s/
```

You can read more about the various YAMLs applied [here](./ghost/README.md).
