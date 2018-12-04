FROM microsoft/vsts-cli

RUN apk update \
  && apk add --no-cache jq

LABEL version="1.0.0"

LABEL maintainer="Microsoft Corporation" 
LABEL com.github.actions.name="Trigger Azure Pipelines" 
LABEL com.github.actions.description="GitHub Action to trigger Azure pipeline" 
LABEL com.github.actions.color="blue"  

COPY entrypoint.sh /entrypoint.sh  
RUN chmod +x /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]
