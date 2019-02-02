#!/bin/bash

set -e 

if [ -z "$AZURE_BOARDS_ORGANIZATION" ]; 
then
    echo "\$AZURE_BOARDS_ORGANIZATION is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_PROJECT" ]; 
then
    echo "\$AZURE_BOARDS_PROJECT is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_TOKEN" ]; 
then
    echo "\$AZURE_BOARDS_TOKEN is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_TYPE" ]; 
then
    echo "\$AZURE_BOARDS_TYPE is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_TITLE" ]; 
then
    echo "\$AZURE_BOARDS_TITLE is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_DESCRIPTION" ]; 
then
    echo "\$AZURE_BOARDS_DESCRIPTION is not set." >&2
    exit 1
fi
    
AZDEVOPS_URL="https://dev.azure.com/${AZURE_BOARDS_ORGANIZATION}/"
vsts configure --defaults instance=${AZDEVOPS_URL} project="${AZURE_BOARDS_PROJECT}"
    
vsts login --token ${AZURE_BOARDS_TOKEN}

BOARDS_CREATE=$( vsts work item create --type "${AZURE_BOARDS_TYPE}" --title "${AZURE_BOARDS_TITLE}" --description "${AZURE_BOARDS_DESCRIPTION}" -f 80="FromGitHub" --output json )



