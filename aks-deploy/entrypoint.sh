#!/bin/sh

set -e

# Respect AZ_OUTPUT_FORMAT if specified
[ -n "$AZ_OUTPUT_FORMAT" ] || export AZ_OUTPUT_FORMAT=json

if [ -n "$AZURE_SERVICE_PEM" ]; then
  mkdir -p "$HOME/.az"
  echo "$AZURE_SERVICE_PEM" > "$HOME/.az/key.pem"
  export AZURE_SERVICE_PASSWORD="$HOME/.az/key.pem"
fi

if [ -n "$AZURE_SERVICE_APP_ID" ] && [ -n "$AZURE_SERVICE_PASSWORD" ] && [ -n "$AZURE_SERVICE_TENANT" ]; then
  az login --service-principal --username "$AZURE_SERVICE_APP_ID" --password "$AZURE_SERVICE_PASSWORD" --tenant "$AZURE_SERVICE_TENANT"
fi

az aks get-credentials --name "$AKS_CLUSTER_NAME" --resource-group "$RESOURCE_GROUP"

if [ -n "$DOCKER_REGISTRY_URL" ] && [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
  echo "Adding docker secrets"
  kubectl create secret docker-registry dockerPullSecret --docker-server=$DOCKER_REGISTRY_URL --docker-username=$DOCKER_USERNAME --docker-password=$DOCKER_PASSWORD
fi

helm init

if [ -n "$HELM_CHART_PATH" ]; then
  echo "Creating a helm chart"
  helm create aksdeploy
  HELM_CHART_PATH=./aksdeploy
  helm upgrade --install --force --set image.repository=$IMAGE_NAME --set image.tag=latest --set service.type=LoadBalancer aksdeploy $HELM_CHART_PATH 
else
  helm upgrade --install --force $* aksdeploy $HELM_CHART_PATH 
fi