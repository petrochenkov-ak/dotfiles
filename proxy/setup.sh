#!/usr/bin/env bash

( set -x; networksetup -listallnetworkservices )
pac_base64=$(cat "${BASH_SOURCE[0]%/*}"/proxy.pac | base64)
( set -x; sudo networksetup -setautoproxyurl "Wi-Fi" "data:application/x-javascript-config;base64,$pac_base64" )
( set -x; networksetup -getautoproxyurl "Wi-Fi" )
# sudo networksetup -setautoproxystate "Wi-Fi" off
( set -x; scutil --proxy | grep -i ProxyAutoConfig )

# cd "$HOME/.config/ssh-proxy" && python3 -c '
import http.server, socketserver

class ThreadedHTTPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True

http.server.SimpleHTTPRequestHandler.extensions_map[".pac"] = "application/x-ns-proxy-autoconfig"
ThreadedHTTPServer(("127.0.0.1", 8099), http.server.SimpleHTTPRequestHandler).serve_forever()
'

full_url="http://127.0.0.1:8099/proxy.pac"
( set -x; sudo networksetup -setautoproxyurl "Wi-Fi" "$full_url" )
