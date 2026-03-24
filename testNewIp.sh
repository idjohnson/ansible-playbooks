#!/bin/bash 

export NOTIFYPASS=$1

MYIP="`host -4 myip.opendns.com resolver1.opendns.com | tail -n1 | sed 's/.* //' | tr -d '\n'`"
HARBOR="`host -4 harbor.freshbrewed.science resolver1.opendns.com | tail -n1 | sed 's/.* //' | tr -d '\n'`"

if [ "$MYIP" = "$HARBOR" ]; then
   echo "Strings are Equal . $MYIP matches $HARBOR"

   # Notify
   curl -X POST -H 'Content-Type: application/json' https://notify.tpk.pw/notify -d "{\"title\": \"AWX: homelab IP STILL GOOD\", \\"message\": \"IP of h.f.s is $HARBOR and egress is still $MYIP\", \"priority\": 5, \"password\": \"$NOTIFYPASS\"}"
else
   echo "IP CHANGED!  Harbor $HARBOR does not match local $MYIP"

   # Notify
   curl -X POST -H 'Content-Type: application/json' https://notify.tpk.pw/notify -d "{\"title\": \"AWX: homelab IP change\", \\"message\": \"IP changed from $HARBOR to $MYIP\", \"priority\": 5, \"password\": \"$NOTIFYPASS\"}"

   # light
   wget "https://kasarest.freshbrewed.science/on?devip=192.168.1.24&apikey=$1"
   exit 1
fi

