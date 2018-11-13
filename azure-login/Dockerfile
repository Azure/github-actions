FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"

LABEL maintainer="Disha Khakhar"
LABEL com.github.actions.name="Azure Login"
LABEL com.github.actions.description="GitHub Action to login in to Azure"
LABEL com.github.actions.icon="triange"
LABEL com.github.actions.color="blue"

ENTRYPOINT az login --service-principal --username "$AZURE_SERVICE_APP_ID" --password "$AZURE_SERVICE_PASSWORD" --tenant "$AZURE_SERVICE_TENANT"