#!/bin/bash

set -e

az group create --name "$RESOURCE_GROUP_NAME" --location "$RESOURCE_GROUP_LOCATION"

URI_REGEX="^(http://|https://)\\w+"

if [[ $TEMPLATE_FILE =~ $URI_REGEX ]]
then
  az group deployment create -g "$RESOURCE_GROUP_NAME" --name "$DEPLOYMENT_NAME" --template-uri "$TEMPLATE_FILE" --parameters "@$GITHUB_WORKSPACE/$PARAMETERS_FILE_PATH"
else
  az group deployment create -g "$RESOURCE_GROUP_NAME" --name "$DEPLOYMENT_NAME" --template-file "$GITHUB_WORKSPACE/$TEMPLATE_FILE" --parameters "@$GITHUB_WORKSPACE/$PARAMETERS_FILE_PATH"
fi