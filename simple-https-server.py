#!/usr/bin/env python
import BaseHTTPServer, SimpleHTTPServer
import ssl
import sys
import argparse

ap = argparse.ArgumentParser()
ap.add_argument('--certfile')
ap.add_argument('--keyfile')
ap.add_argument('--port', type=int, default=443)
ap.add_argument('--hostname', default='localhost')
args = ap.parse_args()

url = 'https://' + args.hostname
if args.port != 443:
    url += ':' + str(args.port)
url += '/'

httpd = BaseHTTPServer.HTTPServer((args.hostname, args.port), SimpleHTTPServer.SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket (httpd.socket, certfile=args.certfile, keyfile=args.keyfile, server_side=True)

print("Serving at" + url)
httpd.serve_forever()
