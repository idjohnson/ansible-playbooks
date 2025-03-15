#!/bin/bash

# Check if required arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <azure_devops_org> <poolname> <pat_token>"
    echo "Example: $0 myorganization mypoolname pat_token_value"
    exit 1
fi

AZURE_ORG="$1"
PAT_TOKEN="$2"
AGENT_NAME=$(hostname)
POOL_NAME="$3"
MYUSERNAME=$(whoami)

# Create and navigate to agent directory
mkdir -p ./myagent
cd ./myagent

wget https://vstsagentpackage.azureedge.net/agent/4.252.0/vsts-agent-linux-x64-4.252.0.tar.gz
# Extract the agent package
tar zxvf ./vsts-agent-linux-x64-4.252.0.tar.gz

# Configure the agent
./config.sh --unattended \
    --url "https://dev.azure.com/${AZURE_ORG}" \
    --auth pat \
    --token "${PAT_TOKEN}" \
    --pool "${POOL_NAME}" \
    --agent "${AGENT_NAME}" \
    --acceptTeeEula \
    --work ./_work

sudo ./svc.sh install $MYUSERNAME

sudo ./svc.sh start

rm ./myagent/vsts-agent-linux-x64-4.252.0.tar.gz

