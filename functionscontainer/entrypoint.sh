#!/bin/bash

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION}_${GITHUB_REPOSITORY}"

AZURE_CR_SUFFIX="azurecr.io"

if [[ -z $AZURE_APP_NAME ]];
then 
    echo "Required Azure Function App Name. Provide value in AZURE_APP_NAME variable" >&2
    exit 1
fi

echo "Azure Function App Name: ${AZURE_APP_NAME}"

if [[ -z $CONTAINER_IMAGE_NAME ]];
then
    echo "Required container image name. Provide Value in CONTAINER_IMAGE_NAME." >&2
    exit 1
fi

RESOURCE_GROUP_NAME=`az resource list -n "${AZURE_APP_NAME}" --resource-type "Microsoft.Web/Sites" --query '[0].resourceGroup' | xargs`

if [[ -z $RESOURCE_GROUP_NAME ]];
then
    echo "Azure Function App '${AZURE_APP_NAME}' should exist before deployment." >&2
    exit 1
fi

if [[ $DOCKER_REGISTRY_URL =~ "$AZURE_CR_SUFFIX" ]];
then
    # remove http:// and https:// before appending container name to image
    DOCKER_REGISTRY_NAME=${DOCKER_REGISTRY_URL#"http://"}
    DOCKER_REGISTRY_NAME=${DOCKER_REGISTRY_NAME#"https://"}

    if [[ ! CONTAINER_IMAGE_NAME =~ "$DOCKER_REGISTRY_NAME" ]];
    then
        # Append container name with image
        CONTAINER_IMAGE_NAME="$DOCKER_REGISTRY_NAME/$CONTAINER_IMAGE_NAME"
    fi
fi

echo "Resource Group Name: ${RESOURCE_GROUP_NAME}"


WEBSITES_ENABLE_APP_SERVICE_STORAGE=`az webapp config appsettings list -n ${AZURE_APP_NAME} -g ${RESOURCE_GROUP_NAME} --query "[?(@.name=='WEBSITES_ENABLE_APP_SERVICE_STORAGE')].value" -o tsv`

if [[ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE == "false" ]];
then
    echo "Setting App Setting WEBSITES_ENABLE_APP_SERVICE_STORAGE = false ..."
    az webapp config appsettings set -g "${RESOURCE_GROUP_NAME}" -n "${AZURE_APP_NAME}" --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=false > /dev/null
    echo "Set WEBSITES_ENABLE_APP_SERVICE_STORAGE = false successfully!"
fi

AZCLI_ARGUMENT=" --docker-custom-image-name ${CONTAINER_IMAGE_NAME}"

if [[ ! -z $CONTAINER_IMAGE_TAG ]];
then
    AZCLI_ARGUMENT="${AZCLI_ARGUMENT}:${CONTAINER_IMAGE_TAG}"
fi

if [[ ! -z $DOCKER_USERNAME && ! -z $DOCKER_PASSWORD ]];
then
    AZCLI_ARGUMENT="${AZCLI_ARGUMENT} --docker-registry-server-user ${DOCKER_USERNAME} --docker-registry-server-password ${DOCKER_PASSWORD}"
fi

if [[ ! -z $DOCKER_REGISTRY_URL ]]
then
    AZCLI_ARGUMENT="${AZCLI_ARGUMENT} --docker-registry-server-url ${DOCKER_REGISTRY_URL}"
fi

echo "Initiating Container deployment..."

az webapp config container set -n "${AZURE_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" $AZCLI_ARGUMENT

echo "Configured image details to Azure Function App"

DESTINATION_URL=`az webapp deployment list-publishing-profiles -n ${AZURE_APP_NAME} -g ${RESOURCE_GROUP_NAME} --query '[0].destinationAppUrl' -o tsv`
echo "Azure Function App Application URL: ${DESTINATION_URL}"
