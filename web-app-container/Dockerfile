FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"
LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="Deploy to Azure WebappContainer"
LABEL com.github.actions.description="GitHub Action for Function App container deployment - ACR, Docker and private registries"
LABEL com.github.actions.icon="cloud"
LABEL com.github.actions.color="blue"

COPY . .

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]