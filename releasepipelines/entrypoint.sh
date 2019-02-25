#!/bin/bash
set -e

if [ -z "$AZURE_PIPELINE_ORGANIZATION" ]; 
then
    echo "\$AZURE_PIPELINE_ORGANIZATION is not set."
    exit 1
fi

if [ -z "$AZURE_PIPELINE_PROJECT" ];
then
    echo "\$AZURE_PIPELINE_PROJECT is not set."
    exit 1
fi

if [ -z "$AZURE_PIPELINE_TOKEN" ]; 
then
    echo "\$AZURE_PIPELINE_TOKEN is not set."
    exit 1
fi

if [ -z "$AZURE_PIPELINE_NAME" ]; 
then
    echo "\$AZURE_PIPELINE_NAME is not set."
    exit 1
fi

    
AZDEVOPS_URL="https://dev.azure.com/${AZURE_PIPELINE_ORGANIZATION}/"
az devops configure --defaults instance="${AZDEVOPS_URL}" project="${AZURE_PIPELINE_PROJECT}"
    
az devops login --token "${AZURE_PIPELINE_TOKEN}"

# List RDs with given pipeline name
PIPELINES=$(az pipelines release definition list --name "${AZURE_PIPELINE_NAME}")

if ! (echo "${PIPELINES}" | jq -e .); then
    echo "Failed to fetch release definitions. Error: ${PIPELINES}"
    exit 1;
fi 

COUNT=$(echo "${PIPELINES}" | jq length)

if [ "$COUNT" -eq 0 ]
then
   echo "No release definition found with name: '${AZURE_PIPELINE_NAME}'". >&2
   exit 1;
fi

# Filter RDs with exact name
AZURE_PIPELINE_NAME=$(echo "$AZURE_PIPELINE_NAME" | awk '{print tolower($0)}')
COUNT=$(echo "${PIPELINES}" | jq -r ".[]?| .name |=ascii_downcase | select(.name==\"$AZURE_PIPELINE_NAME\")| .name //empty" | wc -l) 

if [ "$COUNT" -gt 1 ]; 
then
    echo "Multple release definitions were found with name: '${AZURE_PIPELINE_NAME}'. Pass unique release definition name and try again." >&2
    exit 1;
fi

if [ "$COUNT" -eq 0 ]
then
   echo "No release definition found with name: '${AZURE_PIPELINE_NAME}'". >&2
   exit 1;
fi


RELEASE_DEFINITION=$(az pipelines release definition show --name "${AZURE_PIPELINE_NAME}")

if ! (echo "${RELEASE_DEFINITION}" | jq -e .); then
    echo "Failed to fetch release pipeline. Error: ${RELEASE_DEFINITION}"
    exit 1;
fi 

TYPE="GitHub"
ARTIFACTS_COUNT=$(echo "${RELEASE_DEFINITION}" | jq -r ".artifacts?[]? | select((.type==\"$TYPE\") and .definitionReference.definition.name==\"$GITHUB_REPOSITORY\") | length" | wc -l)

if [ "$ARTIFACTS_COUNT" -gt 1 ];
then
    echo "More than 1 artifact found with same repository and repository type."
    exit 1;
fi

ALIAS=$(echo "${RELEASE_DEFINITION}" | jq -r ".artifacts[]? | select((.type==\"$TYPE\") and .definitionReference.definition.name==\"$GITHUB_REPOSITORY\") | .alias //empty")
if [ -n "$ALIAS" ]; 
then
    echo "Triggering Azure release pipeline for : '${AZURE_PIPELINE_NAME}' for commitId: '${GITHUB_SHA}'."
    az pipelines release create --definition-name "${AZURE_PIPELINE_NAME}" --artifact-metadata-list "$ALIAS"="$GITHUB_SHA"
else
    echo "Triggering Azure release pipeline: '${AZURE_PIPELINE_NAME}'"
    az pipelines release create --definition-name "${AZURE_PIPELINE_NAME}"
fi  
