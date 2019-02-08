#!/bin/bash

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION_NAME}_${GITHUB_REPOSITORY}"

AZURE_CR_SUFFIX="azurecr.io"

if [[ -z $AZURE_APP_NAME ]];
then 
    echo "Required Web App Name. Provide value in AZURE_APP_NAME variable" >&2
    exit 1
fi

echo "Web App Name: ${AZURE_APP_NAME}"

if [[ -z $CONTAINER_IMAGE_NAME ]];
then
    echo "Required container image name. Provide Value in CONTAINER_IMAGE_NAME." >&2
    exit 1
fi

RESOURCE_GROUP_NAME=$(az resource list -n "${AZURE_APP_NAME}" --resource-type "Microsoft.Web/Sites" --query '[0].resourceGroup' | xargs)

if [[ -z $RESOURCE_GROUP_NAME ]];
then
    echo "Web App '${AZURE_APP_NAME}' should exist before deployment." >&2
    exit 1
fi


if [[ $DOCKER_REGISTRY_URL =~ $AZURE_CR_SUFFIX ]];
then
    # remove http:// and https:// before appending container name to image
    DOCKER_REGISTRY_NAME=${DOCKER_REGISTRY_URL#"http://"}
    DOCKER_REGISTRY_NAME=${DOCKER_REGISTRY_NAME#"https://"}

    if [[ ! CONTAINER_IMAGE_NAME =~ $DOCKER_REGISTRY_NAME ]];
    then
        # Append container name with image
        CONTAINER_IMAGE_NAME="$DOCKER_REGISTRY_NAME/$CONTAINER_IMAGE_NAME"
    fi
fi

echo "Resource Group Name: ${RESOURCE_GROUP_NAME}"

if [[ -n $CONTAINER_IMAGE_TAG ]];
then
    CONTAINER_IMAGE_NAME="${CONTAINER_IMAGE_NAME}:${CONTAINER_IMAGE_TAG}"
fi

echo "Initiating Container deployment..."

if [[ -n $DOCKER_USERNAME && -n $DOCKER_PASSWORD && -n $DOCKER_REGISTRY_URL ]]; then
    az webapp config container set -n "${AZURE_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" \
        --docker-custom-image-name "${CONTAINER_IMAGE_NAME}" \
        --docker-registry-server-user "${DOCKER_USERNAME}" \
        --docker-registry-server-password "${DOCKER_PASSWORD}" \
        --docker-registry-server-url "${DOCKER_REGISTRY_URL}"
elif [[ -n $DOCKER_USERNAME && -n $DOCKER_PASSWORD ]]; then
    az webapp config container set -n "${AZURE_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" \
        --docker-custom-image-name "${CONTAINER_IMAGE_NAME}" \
        --docker-registry-server-user "${DOCKER_USERNAME}" \
        --docker-registry-server-password "${DOCKER_PASSWORD}" 
elif [[ -n $DOCKER_REGISTRY_URL ]]; then
    az webapp config container set -n "${AZURE_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" \
        --docker-custom-image-name "${CONTAINER_IMAGE_NAME}" \
        --docker-registry-server-url "${DOCKER_REGISTRY_URL}"
else 
    az webapp config container set -n "${AZURE_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" \
        --docker-custom-image-name "${CONTAINER_IMAGE_NAME}"
fi

echo "Configured image details to Azure Web App"

DESTINATION_URL=$(az webapp deployment list-publishing-profiles -n "${AZURE_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" --query '[0].destinationAppUrl' -o tsv)
echo "Web App Application URL: ${DESTINATION_URL}"
