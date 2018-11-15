#!/bin/bash

set -e

# Create Resource group if it does not exists

RESOURCE_GROUP_EXISTS=$(az group exists -n "$AZURE_RESOURCE_GROUP")
if [[ $RESOURCE_GROUP_EXISTS == "false" ]]
then
  if [[ -z "$RESOURCE_GROUP_LOCATION" ]]
  then
    echo "RESOURCE_GROUP_LOCATION is not set."
  else
    az group create --name "$AZURE_RESOURCE_GROUP" --location "$RESOURCE_GROUP_LOCATION"
  fi
fi

URI_REGEX="^(http://|https://)\\w+"
GUID=$(uuidgen | cut -d '-' -f 1)

# Download parameters file if it is a remote URL

if [[ $AZURE_TEMPLATE_PARAM_FILE =~ $URI_REGEX ]]
then
  PARAMETERS_FILE="parameters-${GUID}.json"
  TEMPLATE_PARAMETERS=$(curl $AZURE_TEMPLATE_PARAM_FILE)
  echo ${TEMPLATE_PARAMETERS} >> $PARAMETERS_FILE
  echo "Downloaded parameters into file ${PARAMETERS_FILE}"
else
  PARAMETERS_FILE="${GITHUB_WORKSPACE}/${AZURE_TEMPLATE_PARAM_FILE}"
  if [[ ! -e "$PARAMETERS_FILE" ]]
  then
    echo "Parameters file ${PARAMETERS_FILE} does not exists."
    exit 1
  fi
fi

# Generate deployment name if not specified

if [[ -z "$DEPLOYMENT_NAME" ]]
then
  DEPLOYMENT_NAME="Github-Action-ARM-${GUID}"
  echo "Generated Deployment Name ${DEPLOYMENT_NAME}"
fi

# Deploy ARM template

if [[ $AZURE_TEMPLATE_LOCATION =~ $URI_REGEX ]]
then
  az group deployment create -g "$AZURE_RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --template-uri "$AZURE_TEMPLATE_LOCATION" --parameters "@$PARAMETERS_FILE"
else
  TEMPLATE_FILE="${GITHUB_WORKSPACE}/${AZURE_TEMPLATE_LOCATION}"
  if [[ ! -e "$TEMPLATE_FILE" ]]
  then
    echo "Template file ${TEMPLATE_FILE} does not exists."
  else
    az group deployment create -g "$AZURE_RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --template-file "$TEMPLATE_FILE" --parameters "@$PARAMETERS_FILE"
  fi
fi