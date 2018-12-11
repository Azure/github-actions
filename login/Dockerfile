FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"

LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="Azure Login"
LABEL com.github.actions.description="GitHub Action to login in to Azure"
LABEL com.github.actions.icon="triange"
LABEL com.github.actions.color="blue"

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]