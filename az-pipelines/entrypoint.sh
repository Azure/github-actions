#!/bin/bash

set -e 

if [ -z "$AZURE_PIPELINE_ORGANIZATION" ]; 
then
    echo "\$AZURE_PIPELINE_ORGANIZATION is not set." >&2
    exit 1
fi

if [ -z "$AZURE_PIPELINE_PROJECT" ]; 
then
    echo "\$AZURE_PIPELINE_PROJECT is not set." >&2
    exit 1
fi

if [ -z "$AZURE_PIPELINE_TOKEN" ]; 
then
    echo "\$AZURE_PIPELINE_TOKEN is not set." >&2
    exit 1
fi

if [ -z "$AZURE_PIPELINE_NAME" ]; 
then
    echo "\$AZURE_PIPELINE_NAME is not set." >&2
    exit 1
fi

    
AZDEVOPS_URL="https://dev.azure.com/${AZURE_PIPELINE_ORGANIZATION}/"
vsts configure --defaults instance=${AZDEVOPS_URL} project=${AZURE_PIPELINE_PROJECT}
    
vsts login --token ${AZURE_PIPELINE_TOKEN}
  
PIPELINES=$( vsts build definition list --name ${AZURE_PIPELINE_NAME} )
COUNT=$( echo ${PIPELINES} | jq length )

if [ $COUNT -eq 0 ]; 
then
   echo "No pipeline found with name: ${AZURE_PIPELINE_NAME}". >&2
   exit 1;
fi

if [ $COUNT -gt 1 ]; 
then
    echo "Multple pipelines were found with name: ${AZURE_PIPELINE_NAME}. Pass unique pipeline name and try again." >&2
    exit 1;
fi

BUILD_DEFINITION_ID=$( echo ${PIPELINES} | jq .[0].id -r )
BUILD_DEFINITION=$( vsts build definition show --id ${BUILD_DEFINITION_ID} )
REPOSITORY_NAME=$( echo ${BUILD_DEFINITION} | jq .repository.name -r )
REPOSITORY_TYPE=$( echo ${BUILD_DEFINITION} | jq .repository.type -r )

if [ "$REPOSITORY_NAME" = "$GITHUB_REPOSITORY" ] && ["$REPOSITORY_TYPE" = "GitHub" ]; 
then
     vsts build queue --definition-name ${AZURE_PIPELINE_NAME} --branch ${GITHUB_REF} --commit-id ${GITHUB_SHA}
else
    BUILD_OUTPUT=$( vsts build queue --definition-name ${AZURE_PIPELINE_NAME} )
    echo "${BUILD_OUTPUT}"
	ERROR="error"
    MESSAGE=$( echo ${BUILD_OUTPUT} | jq -r ".validationResults[] | select(.result==\"$ERROR\") | .message" ) ;
	if [ -n "$MESSAGE" ];
	then
	         echo "Failed to queue build. Reason: ${MESSAGE}" >&2
             exit 1;
	fi
fi