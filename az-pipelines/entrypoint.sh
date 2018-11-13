#!/bin/sh

set -e

if [ -z "$AZURE_PIPELINE_ORGANIZATION" ]; then
    echo "\$AZURE_PIPELINE_ORGANIZATION is not set."
    exit 1
fi

if [ -z "$AZURE_PIPELINE_PROJECT" ]; then
    echo "\$AZURE_PIPELINE_PROJECT is not set."
    exit 1
fi

if [ -z "$AZURE_PIPELINE_TOKEN" ]; then
    echo "\$AZURE_PIPELINE_TOKEN is not set."
    exit 1
fi

if [ -z "$AZURE_PIPELINE_NAME" ]; then
    echo "\$AZURE_PIPELINE_NAME is not set."
    exit 1
fi

    
AZDEVOPS_URL="https://dev.azure.com/${AZURE_PIPELINE_ORGANIZATION}/"
vsts configure --defaults instance=${AZDEVOPS_URL} project=${AZURE_PIPELINE_PROJECT}
    
vsts login --token ${AZURE_PIPELINE_TOKEN}
    
echo "Queueing Azure pipeline: ${AZURE_PIPELINE_NAME}"
vsts build queue --definition-name ${AZURE_PIPELINE_NAME}