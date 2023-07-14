#!/bin/bash 

MYIP="`host -4 myip.opendns.com resolver1.opendns.com | tail -n1 | sed 's/.* //' | tr -d '\n'`"
HARBOR="`host -4 .harbor.freshbrewed.science resolver1.opendns.com | tail -n1 | sed 's/.* //' | tr -d '\n'`"

if [ "$MYIP" = "$HARBOR" ]; then
   echo "Strings are Equal . $MYIP matches $HARBOR"
else
   echo "IP CHANGED!  Harbor $HARBOR does not match local $MYIP"
   wget "https://kasarest.freshbrewed.science/on?devip=192.168.1.24&apikey=$1"
   exit 1
fi
