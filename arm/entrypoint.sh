#!/bin/bash

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION}"

if [[ -z "$AZURE_RESOURCE_GROUP" ]]
then
  echo "AZURE_RESOURCE_GROUP is not set." >&2
  exit 1
fi

if [[ -z "$AZURE_RG_COMMAND" ]] || [[ ${AZURE_RG_COMMAND,,} == 'create' ]]
then
  echo "Executing commands to Create/Update resource group."
  # Create Resource group if it does not exists

  RESOURCE_GROUP_EXISTS=$(az group exists -n "$AZURE_RESOURCE_GROUP")
  if [[ $RESOURCE_GROUP_EXISTS == "false" ]]
  then
      if [[ -z "$RESOURCE_GROUP_LOCATION" ]]
      then
        echo "RESOURCE_GROUP_LOCATION is not set." >&2
        exit 1
      fi
      az group create --name "$AZURE_RESOURCE_GROUP" --location "$RESOURCE_GROUP_LOCATION"
  fi

  URI_REGEX="^(http://|https://)\\w+"
  GUID=$(uuidgen | cut -d '-' -f 1)

  # Download parameters file if it is a remote URL

  if [[ $AZURE_TEMPLATE_PARAM_LOCATION =~ $URI_REGEX ]]
  then
    PARAMETERS=$(curl $AZURE_TEMPLATE_PARAM_LOCATION)
    echo "Downloaded parameters from ${AZURE_TEMPLATE_PARAM_LOCATION}"
  else
    PARAMETERS_FILE="${GITHUB_WORKSPACE}/${AZURE_TEMPLATE_PARAM_LOCATION}"
    if [[ ! -e "$PARAMETERS_FILE" ]]
    then
      echo "Parameters file ${PARAMETERS_FILE} does not exists." >&2
      exit 1
    fi
    PARAMETERS="@${PARAMETERS_FILE}"
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
    az group deployment create -g "$AZURE_RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --template-uri "$AZURE_TEMPLATE_LOCATION" --parameters "$PARAMETERS"
  else
    TEMPLATE_FILE="${GITHUB_WORKSPACE}/${AZURE_TEMPLATE_LOCATION}"
    if [[ ! -e "$TEMPLATE_FILE" ]]
    then
      echo "Template file ${TEMPLATE_FILE} does not exists." >&2
      exit 1
    fi
    az group deployment create -g "$AZURE_RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --template-file "$TEMPLATE_FILE" --parameters "$PARAMETERS"
  fi
elif [[ ${AZURE_RG_COMMAND,,} == 'delete' ]]
then
  echo "Executing commands to Delete resource group."
  az group delete -n "$AZURE_RESOURCE_GROUP" --yes
else
  echo "Invalid AZURE_RG_COMMAND. Allowed values are: CREATE, DELETE." >&2
  exit 1
fi