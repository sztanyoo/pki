pki
===

This is a sample PKI infrastrucure generator. createCerts.sh generates

1. a self-signed certificate as ca to the ca directory
2. a subca signing certificate that is signed by the ca - and has limited scope of validity
3. a leaf certificate signed by subca


Usage
-----

Set `SUBCA_SAN_RESTRICTION` variable in createCerts.sh - this will set limit for what DNS names will the subca be valid.

Set `LEAF_SAN` in createCerts.sh - this will be the SAN for the leaf cert

Run the generator
```
/bin/bash createCerts.sh
```

Answer the default values and approve everywhere.

NOTE: all the certificates are regenerated on each execution


Test the cert on a website
--------------------------
```
docker run --rm -it -p 0.0.0.0:443:443  -v `pwd`:/data python:2 /bin/bash
cd /data
python simple-https-server.py --certfile myservice/web.crt --keyfile myservice/myservice.key --hostname 0.0.0.0
```
Use `service_key_password` as PEM pass phrase