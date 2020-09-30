pki
===

This is a sample PKI infrastrucure generator. There's a bash script, `generateCerts.sh` that does all the work.

*CA* - is the folder where CA's key, cert is generated. It's a self-signed certificate

*SubCA* - is an intermediary CA. It's certificate is limited to `.somedomain.com`. This limitation is added by the CA during signing the subca csr.

*Myservice* - is an example service, who's csr is signed by the subca. Since myservice's cert is requested for my.otherdomain.com, when a browser tries to use this cert, it will fail the validation.

*Status*: might be useful for demonstraion purposes

Usage
-----

```
/bin/bash createCerts.sh
```

Answer the default values except for the `myservice` CSR. In that case use `myservice` as common name.

Test the cert on a website
--------------------------
```
docker run --rm -it -p 0.0.0.0:443:443  -v `pwd`:/data python:2 /bin/bash
cd /data
python simple-https-server.py --certfile myservice/web.crt --keyfile myservice/myservice.key --hostname 0.0.0.0
```

TODO: myservice shouldn't be a CA cert.
