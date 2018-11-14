#!/bin/sh

set -e

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
  if [ -n "$DOCKER_EMAIL" ]; then
    kubectl create secret docker-registry docker-pull-secret --docker-server=$DOCKER_REGISTRY_URL --docker-username=$DOCKER_USERNAME --docker-password=$DOCKER_PASSWORD --docker-email=$DOCKER_EMAIL --dry-run -o json | kubectl apply -f -
  else
    kubectl create secret docker-registry docker-pull-secret --docker-server=$DOCKER_REGISTRY_URL --docker-username=$DOCKER_USERNAME --docker-password=$DOCKER_PASSWORD --docker-email=default@example.com --dry-run -o json | kubectl apply -f -
  fi
fi

helm init

DEFAULT_ARGS=""

if [ -z "$HELM_CHART_PATH" ]; then
  echo "Using a default helm chart"
  HELM_CHART_PATH=/default-chart
  if [ -n "$IMAGE_TAG" ]; then
    IMAGE_NAME=$IMAGE_NAME:$IMAGE_TAG
  fi
  DEFAULT_ARGS="--set image.repository=$IMAGE_NAME"
fi

helm upgrade --install --force $DEFAULT_ARGS $* aksdeploy $HELM_CHART_PATH