Certificate Creation
--------------------

The scripts in this folder create a self-managed certificate authority and generate scripts that can be used for each Helm and Tiller instance.

These certificates allow Helm and Tiller to securely communicate with one another, see the Helm documentation on the topic [here](https://helm.sh/docs/using_helm/#generating-certificate-authorities-and-certificates).

Certificate and key generation were based on this tutorial: # Based on this tutorial: https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

Notes on Certificate Creation
-----------------------------

The following fields are mandatory. You will not be prevented from proceeding immediately if they are not included, but you will not be able to complete later requests:

```
Country Name
State or Province Name
Organization Name
Organizational Unit Name
Common Name*
Email Address
```

*In particular, the `Common Name` must differ for each certificate.

Scripts
-------

- `generate_certificates.sh`: Generates the keys and certificates necessary to implement TLS for the Kubernetes cluster. Further detailed below.
- `clean_certificates.sh`: Removes all keys certificates and resets this directory to a clean state.

Generate Certificates
---------------------
This script handles creation of three levels of keys and certificates:
1. Root, `root/ca/` - The top-level key and certificate for this authority. This key should be stored with the most security, ideally offline.
2. Intermediate, `intermediate/` - An intermediate certificate level that will be used to issue certificates to clients. It can be replaced by the root authority if it has been compromised.
3. Client, `client/` - Certificates that can be used by the clients to securely interact with one another. In our case, two certificates are created, for our DEV and PROD environments.