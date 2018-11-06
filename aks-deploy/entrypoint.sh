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

echo "Creating a spec file for: $IMAGE_NAME"
cat /deployment.yaml | awk '{sub(/__IMAGE_NAME__/,"'$IMAGE_NAME'")}1' > deployment.yaml

kubectl apply -f deployment.yaml
