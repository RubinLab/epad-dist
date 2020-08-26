FROM node:lts-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN npm install pm2 -g

ARG ARG_EPAD_DOCKER_GID
#USER root

# check docker gid exist in container.
# if exists add user "node" to the group which matches the given gid else add reqired gid in the container and add user "node" to the group
# IMPORTANT group names may not match inside and outside but gid in the container must match outside gid. example: group name "docker(gid=999)" outside may have 
# the group name "ping(gid=999)" in container.  

USER root && RUN if [[ -z "$ARG_EPAD_DOCKER_GID" ]] ; \
        then echo gid is empty ; \
        else echo Argument is $ARG_EPAD_DOCKER_GID ; \
        tempGid=$(cat /etc/group | grep $ARG_EPAD_DOCKER_GID) ; \
        echo $tempGid ; \
                if [[ -z "$tempGid" ]] ; \
                        then  \
                                 echo temp gid is empty ; \
                                 addgroup -g  $ARG_EPAD_DOCKER_GID docker && adduser node -G docker ; \
                        else  \
                                 echo temp gid is not empty ; \
                                #adduser node ping ; i\
                                groupName=$(echo "$tempGid" | cut -d: -f1) && echo $groupName && adduser node $groupName ; \
                fi ; \
        fi

USER node
RUN mkdir -p /home/node/app
WORKDIR /home/node/app

RUN git clone https://github.com/RubinLab/epadlite.git /home/node/app/


# Install app dependencies
ENV NPM_CONFIG_LOGLEVEL warn
RUN npm install --development

# Expose the listening port of your app
EXPOSE 8080

# Show current folder structure in logs
RUN ls -al -R

CMD [ "pm2-runtime", "start", "ecosystem.config.js" ]
