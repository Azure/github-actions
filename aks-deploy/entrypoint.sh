#!/bin/sh

set -e

if [ -n "$KUBECONFIG_CONTENTS" ]; then
  echo "$KUBECONFIG_CONTENTS" > kubeconfig
  export KUBECONFIG=./kubeconfig
fi

if [ -z "$KUBECONFIG" ]; then

  if [ -z "$AKS_CLUSTER_NAME" ]; then
      echo "\$AKS_CLUSTER_NAME is not set."
      exit 1
  fi

  if [ -z "$RESOURCE_GROUP" ]; then
    AMBIGUOUS=$(az resource list --name $AKS_CLUSTER_NAME --resource-type Microsoft.ContainerService/managedClusters --query "[1].resourceGroup")
    if [ -n "$AMBIGUOUS" ]; then
      echo "Provided AKS cluster name is ambiguous, provide \$RESOURCE_GROUP to identify the cluster correctly"
      exit 1
    else
      RESOURCE_GROUP=$(az resource list --name $AKS_CLUSTER_NAME --resource-type Microsoft.ContainerService/managedClusters --query "[0].resourceGroup" -o tsv)
      
      if [ -z "$RESOURCE_GROUP" ]; then
        echo "Ensure the AKS cluster: '${AKS_CLUSTER_NAME}' exists."
        exit 1
      fi
      
      echo "Recognized RG name: $RESOURCE_GROUP"
    fi
  fi

  az aks get-credentials --name $AKS_CLUSTER_NAME --resource-group $RESOURCE_GROUP
  INGRESS_ROUTING_ZONE=$(az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --query "addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName" -o tsv)

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

  if [ -z "$CONTAINER_IMAGE_NAME" ]; then
      echo "\$CONTAINER_IMAGE_NAME  is not set."
      exit 1
  fi

  HELM_CHART_PATH=/default-chart
  
  if [ -n "$CONTAINER_IMAGE_TAG" ]; then
    CONTAINER_IMAGE_NAME=$CONTAINER_IMAGE_NAME:$CONTAINER_IMAGE_TAG 
  fi
  
  DEFAULT_ARGS="--set image.repository=$CONTAINER_IMAGE_NAME"

  if [ -n "${INGRESS_ROUTING_ZONE}" ]; then
    DEFAULT_ARGS="--set image.repository=$CONTAINER_IMAGE_NAME --set ingress.enabled=true --set ingress.hostname=${HELM_RELEASE_NAME}.${INGRESS_ROUTING_ZONE}"
  fi
fi

helm upgrade --install --force $DEFAULT_ARGS $* $HELM_RELEASE_NAME $HELM_CHART_PATH
