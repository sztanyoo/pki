pki
===

This is a sample PKI infrastrucure generator.

*Status*: to be improved

Usage
-----

```
/bin/bash createCerts.sh
```

Answer the default values except for the `myservice` CSR.

Test the cert on a website
--------------------------
```
docker run --rm -it -p 0.0.0.0:443:443  -v `pwd`:/data python:2 /bin/bash
cd /data
python simple-https-server.py --certfile myservice/web.crt --keyfile myservice/myservice.key --hostname 0.0.0.0
```