echo $ARG_EPAD_DOCKER_GID
tempGid=$(cat /etc/group | grep $ARG_EPAD_DOCKER_GID) ; 
echo $tempGid ;
if [[ -z "$tempGid" ]] ; 
    then  
        echo No group with host docker group id $ARG_EPAD_DOCKER_GID ; 
        dockerGid=$(cat /etc/group | grep docker) ; 
        if [[ -z "$dockerGid" ]] ; then
            addgroup -g $ARG_EPAD_DOCKER_GID docker && adduser node docker ; 
            echo Added docker group
        else
            addgroup -g $ARG_EPAD_DOCKER_GID dockerEpad && adduser node dockerEpad ; 
            echo Added dockerEpad group
        fi
    else  
        echo Host docker group id $ARG_EPAD_DOCKER_GID exists ; 
        groupName=$(echo "$tempGid" | cut -d: -f1) && echo $groupName && adduser node $groupName ; 
        echo Added to $groupName group instead
fi ; 