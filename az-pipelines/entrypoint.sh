#!/bin/sh

set -e 

if [ -n "$AZURE_PIPELINE_ORGANIZATION" ] && [ -n "$AZURE_PIPELINE_PROJECT" ]; then
    AZDEVOPS_URL="https://dev.azure.com/${AZURE_PIPELINE_ORGANIZATION}/"
	echo "Configuring Azure pipeline URL: "$AZDEVOPS_URL
    vsts configure --defaults instance=${AZDEVOPS_URL} project=${AZURE_PIPELINE_PROJECT}

	if [ -n "$AZURE_PIPELINE_TOKEN" ]; then
	    vsts login --token ${AZURE_PIPELINE_TOKEN}
		echo "Queueing Azure build pipeline for Pipeline : ${AZURE_PIPELINE_NAME}"
        vsts build queue --definition-name ${AZURE_PIPELINE_NAME}
	fi
fi