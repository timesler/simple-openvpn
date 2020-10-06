#!/bin/bash
set -e

if [ "$#" -ne 1 ]
then
    echo 'USAGE: deploy <IP address or hostname>'
else
    FQDN=$1
    echo 'Stopping containers' && docker stop ovpn-data || echo '  ovpn-data not found'
    docker stop simple-openvpn || echo '  simple-openvpn not found'
    echo 'Removing containers' && docker rm ovpn-data || echo ' ovpn-data not found'
    docker rm simple-openvpn || echo ' simple-openvpn not found'

    echo 'Creating data container'
    docker run --name ovpn-data -v /etc/openvpn busybox

    echo 'Generating OpenVPN config file'
    docker run --volumes-from ovpn-data --rm kylemanna/openvpn:2.4 ovpn_genconfig -u udp://$FQDN:1194 -c

    echo 'Initialising primary key'
    docker run --volumes-from ovpn-data --rm -it kylemanna/openvpn:2.4 ovpn_initpki

    echo 'Starting OpenVPN server'
    docker run --name simple-openvpn --volumes-from ovpn-data -d --rm --restart=always -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn:2.4
    echo 'Setup complete'

    echo ''
    docker ps | grep simple-openvpn

    echo '-------------------------------------------------------------------------------------------------------------------'
    echo 'Generate client certificates an config files using:'
    echo '  #> CLIENTNAME=<client name>'
    echo '  #> docker run --volumes-from ovpn-data --rm -it kylemanna/openvpn:2.4 easyrsa build-client-full $CLIENTNAME nopass'
    echo '  #> docker run --volumes-from ovpn-data --rm kylemanna/openvpn:2.4 ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn'
    echo '-------------------------------------------------------------------------------------------------------------------'
EOF
fi
