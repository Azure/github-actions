FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"

LABEL maintainer="Disha Khakhar"
LABEL com.github.actions.name="Azure CLI"
LABEL com.github.actions.description="GitHub Action to interact with Azure using az cli."
LABEL com.github.actions.icon="triange"
LABEL com.github.actions.color="blue"

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]