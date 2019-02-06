FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"

LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="GitHub Action for Azure"
LABEL com.github.actions.description="Wraps the az CLI to enable common Azure commands."
LABEL com.github.actions.icon="triange"
LABEL com.github.actions.color="blue"

ENV GITHUB_ACTION_NAME="Azure CLI"

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
