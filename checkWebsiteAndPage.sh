#!/bin/bash

URL=$1

# Resend.dev
RESTKN=$2
FROME=$3
TOE=$4

echo '{"from":"' | tr -d '\n' > payload.json
echo $FROME | tr -d '\n' >> payload.json
echo '", "to": "' | tr -d '\n' >> payload.json
echo $TOE | tr -d '\n' >> payload.json
echo '", "subject": "' | tr -d '\n' >> payload.json
echo $URL | tr -d '\n' >> payload.json
echo ' in error", "html": "<h1>' | tr -d '\n' >> payload.json
echo $URL | tr -d '\n' >> payload.json



if curl -k -I $URL 2>&1 | grep -q "HTTP/1.1 5"; then 
   echo "$URL Website is returning a 5xx error"

   echo ' generated a 5xx code</h1>"' >> payload.json
   echo '}' >> payload.json

   cat payload.json
   curl -X POST -H "Authorization: Bearer $RESTKN" -H 'Content-Type: application/json' -d @payload.json 'https://api.resend.com/emails'
   exit
else 
   echo "$URL Website is not returning a 5xx error"
fi

if curl -k -I $URL 2>&1 | grep -q "HTTP/1.1 4"; then 
   echo "$URL Website is returning a 4xx error"

   echo ' generated a 4xx code</h1>"' >> payload.json
   echo '}' >> payload.json


   cat payload.json
   curl -X POST -H "Authorization: Bearer $RESTKN" -H 'Content-Type: application/json' -d @payload.json 'https://api.resend.com/emails'
   exit
else 
   echo "$URL Website is not returning a 4xx error"
fi

