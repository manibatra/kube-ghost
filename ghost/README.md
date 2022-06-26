## Ghost Application 

### Files 

#### `namespace.yaml` 
Creates the namespace for the Ghost application.

#### `config.yaml`
Creates the configmap for the Ghost application containing the following configuration:
- url for the Ghost application. 
- following database config options : 
  - client : We use mysql for this example.
  - host : The hostname of the MySQL server.
  - port : The port of the MySQL server.
  - database : The name of the database. 
You can read more about the configuration options provided by Ghost [here](https://ghost.org/docs/config/).

#### `ghost-secret.txt`
Used by `kustomize` to create the secret for the Ghost application containing the following database credentials : 
- user : The username of the MySQL server.
- password : The password of the MySQL server.
- ssl_ca: The database CA certificate.

#### `volume.yaml`
Used to create the Storage Class, Persistent Volume and Persistent Volume Claim for the Ghost application. We mount this at `/var/lib/ghost/content` on the worker node.

#### `deployment.yaml`
Creates the deployment for the Ghost application. Reads the configmap and secret created earlier. Also, mounts the volume created.

#### `service.yaml`
Exposes the Ghost application as a service in the cluster.

#### `ingress.yaml`
Creates the ingress object. We redirect the bare domain to `www.` domain here. To do this: 
- We create the cert with both the bare domain and the www domain.
- We only use the www domain under `rules` in the ingress object.
- We use the annotation `nginx.ingress.kubernetes.io/from-to-www-redirect: "true"` in the ingress object.

#### `do-access-token.txt`
Contains API token for your DNS provider (in this case DigitalOcean). This will be used by the issuer to solve the DNS01 challenge, essentially proving that you control the DNS for the domain that you are trying to request a certificate for. The file is read by `kustomize` to create a secret used by the Issuer.

#### `cert.yaml`
Creates the Issuer and requests the certificate for the Ghost application. You can read more about it [here](https://cert-manager.io/docs/).

#### `kustomization.yaml`
The `kustomize` definition which contains the names of all the resources to apply and the names of the secrets to generate from the text files.
