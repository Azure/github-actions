#!/bin/bash

set -e

if [[ -n "$AZURE_SERVICE_APP_ID" ]] && [[ -n "$AZURE_SERVICE_PASSWORD" ]] && [[ -n "$AZURE_SERVICE_TENANT" ]]
then
  az login --service-principal --username "$AZURE_SERVICE_APP_ID" --password "$AZURE_SERVICE_PASSWORD" --tenant "$AZURE_SERVICE_TENANT"
else
  echo "One of the required parameters for Azure Login is not set: AZURE_SERVICE_APP_ID, AZURE_SERVICE_PASSWORD, AZURE_SERVICE_TENANT."
  exit 1
fi

if [[ -n "$AZURE_SUBSCRIPTION" ]]
then
  az account set --s "$AZURE_SUBSCRIPTION"
else
  SUBSCRIPTIONS=$(az account list)
  if [[ ${#SUBSCRIPTIONS[@]} > 1 ]]
  then
    echo "AZURE_SUBSCRIPTION is not set."
    exit 1
  fi
fi