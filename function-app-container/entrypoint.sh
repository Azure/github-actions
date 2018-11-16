#!/bin/bash

set -e

if [[ -z $WEB_APP_NAME ]];
then 
    echo "Required Web App Name. Provide value in WEB_APP_NAME variable" >&2
    exit 1
fi

echo "Web App Name: ${WEB_APP_NAME}"

if [[ -z $CONTAINER_IMAGE_NAME ]];
then
    echo "Required container image name. Provide Value in CONTAINER_IMAGE_NAME." >&2
    exit 1
fi

RESOURCE_GROUP_NAME=`az resource list -n "${WEB_APP_NAME}" --resource-type "Microsoft.Web/Sites" --query '[0].resourceGroup' | xargs`

if [[ -z $RESOURCE_GROUP_NAME ]];
then
    echo "Web App '${WEB_APP_NAME}' should exist before deployment." >&2
    exit 1
fi

echo "Resource Group Name: ${RESOURCE_GROUP_NAME}"

AZCLI_ARGUMENT=" --docker-custom-image-name ${CONTAINER_IMAGE_NAME}"

if [[ ! -z $CONTAINER_IMAGE_TAG ]];
then
    AZCLI_ARGUMENT="${AZCLI_ARGUMENT}:${CONTAINER_IMAGE_TAG}"
fi

if [[ ! -z $DOCKER_USERNAME && ! -z $DOCKER_PASSWORD ]];
then
    AZCLI_ARGUMENT="${AZCLI_ARGUMENT} --docker-registry-server-user ${DOCKER_USERNAME} --docker-registry-server-password ${DOCKER_PASSWORD}"
fi

if [[ ! -z $DOCKER_REGISTRY_SERVER_URL ]]
then
    AZCLI_ARGUMENT="${AZCLI_ARGUMENT} --docker-registry-server-url ${DOCKER_REGISTRY_SERVER_URL}"
fi

echo "Initiating Container deployment..."

az webapp config container set -n "${WEB_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" $AZCLI_ARGUMENT

echo "Configured image details to Azure App Service"

DESTINATION_URL=`az webapp deployment list-publishing-profiles -n ${WEB_APP_NAME} -g ${RESOURCE_GROUP_NAME} --query '[0].destinationAppUrl' -o tsv`
echo "App Service Application URL: ${DESTINATION_URL}"
