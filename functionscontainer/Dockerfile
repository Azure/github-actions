FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"
LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="Deploy containers on Azure Function App"
LABEL com.github.actions.description="GitHub Action for Azure Web App container deployment - ACR, Docker and private registries"
LABEL com.github.actions.icon="cloud"
LABEL com.github.actions.color="blue"

ENV GITHUB_ACTION_NAME="Deploy containers on Azure Function App"

COPY . .

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]