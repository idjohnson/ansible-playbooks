#!/bin/bash

# find my local IP
export MYIP=`ifconfig | grep 192.168.1 | head -n1 | sed 's/^.*inet \(.*\)  netmask.*/\1/' | tr -d '\n'`
export MYHOST=`ifconfig | grep 192.168.1 | head -n1 | sed 's/^.*inet 192.168.1.\(.*\)  netmask.*/\1/' |
 tr -d '\n'`

# create local int
cat /etc/rancher/k3s/k3s.yaml | sed "s/127.0.0.1/$MYIP/g" | tee /tmp/k8s-int

# save in AKV
az keyvault secret set --vault-name idjakv --name int$MYHOST-int --file /tmp/k8s-int
