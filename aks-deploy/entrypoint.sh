#!/bin/sh

set -e

if [ -z "$AKS_CLUSTER_NAME" ]; then
    echo "\$AKS_CLUSTER_NAME is not set."
    exit 1
fi

if [ -n "$AZURE_SERVICE_PEM" ]; then
  mkdir -p "$HOME/.az"
  echo "$AZURE_SERVICE_PEM" > "$HOME/.az/key.pem"
  export AZURE_SERVICE_PASSWORD="$HOME/.az/key.pem"
fi

if [ -z "$RESOURCE_GROUP" ]; then
  AMBIGUOUS=$(az resource list --name $AKS_CLUSTER_NAME --resource-type Microsoft.ContainerService/managedClusters --query "[1].resourceGroup")
  if [ -n "$AMBIGUOUS" ]; then
    echo "Provided AKS cluster name is ambiguous, provide \$RESOURCE_GROUP to identify the cluster correctly"
    exit 1
  else
    RESOURCE_GROUP=$(az resource list --name $AKS_CLUSTER_NAME --resource-type Microsoft.ContainerService/managedClusters --query "[0].resourceGroup" -o tsv)
    
    if [ -n "$RESOURCE_GROUP" ]; then
      echo "Ensure the AKS cluster: '${AKS_CLUSTER_NAME}' exists."
      exit 1
    fi
    
    echo "Recognized RG name: $RESOURCE_GROUP"
  fi
fi

if [ -z "$KUBECONFIG" ]; then
  az aks get-credentials --name $AKS_CLUSTER_NAME --resource-group $RESOURCE_GROUP
  INGRESS_ROUTING_ZONE=$(az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --query "addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName")
fi

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

if [ -z "$HELM_RELEASE_NAME" ]; then
  HELM_RELEASE_NAME=aks-deploy
fi

if [ -z "$HELM_CHART_PATH" ]; then
  echo "Using a default helm chart"

  if [ -z "$IMAGE_NAME" ]; then
      echo "\$IMAGE_NAME is not set."
      exit 1
  fi

  HELM_CHART_PATH=/default-chart
  if [ -n "$IMAGE_TAG" ]; then
    IMAGE_NAME=$IMAGE_NAME:$IMAGE_TAG
  fi
  DEFAULT_ARGS="--set image.repository=$IMAGE_NAME"

  if [ -n "${INGRESS_ROUTING_ZONE}" ]; then
    DEFAULT_ARGS="${DEFAULT_ARGS} --set ingress.enabled=true --set ingress.hostname=${}.${INGRESS_ROUTING_ZONE}"
  fi
fi

helm upgrade --install --force $DEFAULT_ARGS $* $HELM_RELEASE_NAME $HELM_CHART_PATH