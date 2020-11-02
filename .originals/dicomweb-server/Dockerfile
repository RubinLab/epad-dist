FROM node:lts-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN npm install pm2 -g

USER node
# install dcmtk-node
RUN mkdir -p /home/node/dcmtk-node
WORKDIR /home/node/dcmtk-node
RUN git clone https://github.com/jmhmd/dcmtk-node.git /home/node/dcmtk-node/
RUN npm install

RUN mkdir -p /home/node/app
WORKDIR /home/node/app

RUN git clone https://github.com/dcmjs-org/dicomweb-server.git /home/node/app/

COPY ecosystem.config.js /home/node/app/.

# Install app dependencies
ENV NPM_CONFIG_LOGLEVEL warn
RUN npm install --development

# Expose the listening port of your app
EXPOSE 8090

# Show current folder structure in logs
RUN ls -al -R

CMD [ "pm2-runtime", "start", "ecosystem.config.js" ]