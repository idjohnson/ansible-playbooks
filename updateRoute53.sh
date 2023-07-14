#!/bin/bash
set -x

export FROMHZ=$1
export FROMHN=$2

export AWSKEY=$3
export AWSSECRET=$4

export MYIP="`host -4 myip.opendns.com resolver1.opendns.com | tail -n1 | sed 's/.* //' | tr -d '\n'`"
export FROMIP="`host -4 $FROMHN resolver1.opendns.com | tail -n1 | sed 's/.* //' | tr -d '\n'`"

export AWS_ACCESS_KEY_ID=$AWSKEY
export AWS_SECRET_ACCESS_KEY=$AWSSECRET

# Just show the output
aws route53 list-resource-record-sets --hosted-zone-id $FROMHZ | jq ".ResourceRecordSets[] | select(.ResourceRecords[0].Value==\"$FROMIP\")" | sed 's/^{/{ "Action": "UPSERT", "ResourceRecordSet": {/g' | sed 's/^}/} },/g' | sed "s/$FROMIP/$MYIP/" | tr -d '\n' | xargs -0 -I {} echo ' {"Comment": "Update All Homed IPs to New IP", "Changes": [ {}] }' | sed 's/},] }/} ] }/g' | jq

# if final parmam is "DOIT" then do it.
if [ "$5" = "DOIT" ]; then
   echo "Modifying HZ"
   echo "==================================================="
   rm -f /tmp/MYHugeChangeset.json || true
   aws route53 list-resource-record-sets --hosted-zone-id $FROMHZ | jq ".ResourceRecordSets[] | select(.ResourceRecords[0].Value==\"$FROMIP\")" | sed 's/^{/{ "Action": "UPSERT", "ResourceRecordSet": {/g' | sed 's/^}/} },/g' | sed "s/$FROMIP/$MYIP/" | tr -d '\n' | xargs -0 -I {} echo ' {"Comment": "Update All Homed IPs to New IP", "Changes": [ {}] }' | sed 's/},] }/} ] }/g' | jq > /tmp/MYHugeChangeset.json
   cd /tmp
   aws route53 change-resource-record-sets --hosted-zone-id $FROMHZ --change-batch file://MYHugeChangeset.json
fi
