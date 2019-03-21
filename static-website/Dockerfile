FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"
LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="Deploy to Azure Storage for Static Website Hosting"
LABEL com.github.actions.description="GitHub Action for deploying a static website on Windows / Linux"
LABEL com.github.actions.icon="cloud"
LABEL com.github.actions.color="blue"

ENV GITHUB_ACTION_NAME="Deploy to Azure Storage for Static Website Hosting"

COPY . .

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
