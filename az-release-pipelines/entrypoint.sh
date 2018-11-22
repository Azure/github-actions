#!/bin/bash
set -e

if [ -z "$AZURE_PIPELINE_ORGANIZATION" ]; 
then
    echo "\$AZURE_PIPELINE_ORGANIZATION is not set."
    exit 1
fi

if [-z "$AZURE_PIPELINE_PROJECT" ];
then
    echo "\$AZURE_PIPELINE_PROJECT is not set."
    exit 1
fi

if [-z "$AZURE_PIPELINE_TOKEN" ]; 
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
vsts configure --defaults instance=${AZDEVOPS_URL} project=${AZURE_PIPELINE_PROJECT}
    
vsts login --token ${AZURE_PIPELINE_TOKEN}

PIPELINES=$( vsts release definition list --name ${AZURE_PIPELINE_NAME} )
PIPELINE_COUNT=$( echo ${PIPELINES} | jq length )

if [ $PIPELINE_COUNT -eq 0 ]
then
   echo "No release definition found with name: ${AZURE_PIPELINE_NAME}". >&2
   exit 1;
fi

COUNT=0
echo ${PIPELINES} | jq .[]?.name -r | while read PIPELINE ; 
do
   if [ "$PIPELINE" =  "$AZURE_PIPELINE_NAME" ]; 
   then
       COUNT=`expr $COUNT + 1`
	   if [ $COUNT -gt 1 ]; 
       then
           echo "Multple release definitions were found with name: ${AZURE_PIPELINE_NAME}. Pass unique release definition name and try again." >&2
           exit 1;
        fi
   fi
done

RELEASE_DEFINITION=$( vsts release definition show --name ${AZURE_PIPELINE_NAME} )
echo $RELEASE_DEFINITION
TYPE="GitHub"
ALIAS=$( echo ${RELEASE_DEFINITION} | jq -r ".artifacts[] | select((.type==\"$TYPE\") and .definitionReference.definition.name==\"$GITHUB_REPOSITORY\") | .alias" )

if [ -n "$ALIAS" ]; 
then
    echo "Triggering Azure release pipeline for : ${AZURE_PIPELINE_NAME} for commitId: ${GITHUB_SHA}."
    vsts release create --definition-name ${AZURE_PIPELINE_NAME} --artifact-metadata-list "$ALIAS"="$GITHUB_SHA"
	exit 0
fi
    
echo "Triggering Azure release pipeline: ${AZURE_PIPELINE_NAME}"
vsts release create --definition-name ${AZURE_PIPELINE_NAME}