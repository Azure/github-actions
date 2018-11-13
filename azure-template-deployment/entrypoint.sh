#!/bin/sh

set -e

az group create --name "$RESOURCE_GROUP_NAME" --location "$RESOURCE_GROUP_LOCATION"

if [ -n "${TEMPLATE_FILE_PATH}" ]
then
  az group deployment create -g "${RESOURCE_GROUP_NAME}" --name "${DEPLOYMENT_NAME}" --template-file "${GITHUB_WORKSPACE}/${TEMPLATE_FILE_PATH}" --parameters "@${GITHUB_WORKSPACE}/${PARAMETERS_FILE_PATH}"
else
  az group deployment create -g "${RESOURCE_GROUP_NAME}" --name "${DEPLOYMENT_NAME}" --template-uri "$TEMPLATE_URI" --parameters "@${GITHUB_WORKSPACE}/${PARAMETERS_FILE_PATH}"
fi