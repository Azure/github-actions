FROM nishubansal/localvstscli

RUN apk update \
  && apk add --no-cache jq

LABEL version="1.0.0"

LABEL maintainer="Nishu Bansal" 
LABEL com.github.actions.name="GitHub Action to trigger Azure release pipeline" 
LABEL com.github.actions.description="Trigger Azure devops release pipeline" 
LABEL com.github.actions.color="blue"  

COPY entrypoint.sh /entrypoint.sh  
RUN chmod +x /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]