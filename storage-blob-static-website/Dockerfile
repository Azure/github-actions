FROM microsoft/azure-cli:2.0.64 

LABEL version="1.0.1"
LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="Deploy to Azure Blob Storage for Static Website Hosting"
LABEL com.github.actions.description="GitHub Action for deploying a static website in Azure Blob Storage"
LABEL com.github.actions.icon="cloud"
LABEL com.github.actions.color="blue"

ENV GITHUB_ACTION_NAME="Deploy to Azure Blob Storage for Static Website Hosting"

COPY . .

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
