FROM microsoft/azure-cli

RUN apk update \
  && apk add --no-cache jq

RUN wget http://www.pell.portland.or.us/~orc/Code/discount/discount-2.2.4.tar.bz2 -O /tmp/discount-2.2.4.tar.bz2 \
  && tar xvjf /tmp/discount-2.2.4.tar.bz2 -C /tmp \
  && cd /tmp/discount-2.2.4 \
  && ./configure.sh \
  && make \
  && make install

LABEL version="1.0.0"

LABEL maintainer="Microsoft Corporation" 
LABEL com.github.actions.name="Trigger Azure Boards" 
LABEL com.github.actions.description="GitHub Action to trigger Azure Boards" 
LABEL com.github.actions.color="blue"  

COPY entrypoint.sh /entrypoint.sh  
RUN chmod +x /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]
