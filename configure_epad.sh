# based on https://github.com/jasperes/bash-yaml/blob/master/test/test.sh
replace_in_files(){
    for file in ./$3/*
    do
    if [[ -f $file ]] 
    then
        sed -i -e "s/$1/$2/g" "$file"
    else 
        for inner_file in $file/*
        do
        if [[ -f $inner_file ]] 
        then
            sed -i -e "s/$1/$2/g" "$inner_file"
        fi
        done
        if [ "$(uname)" == "Darwin" ]; then
            rm $file/*-e
        fi

    fi
    done
    if [ "$(uname)" == "Darwin" ]; then
        rm ./$3/*-e
    fi
}

if [[ $# != 2 ]]
then
    echo "Wrong number of parameters. Configuration script needs a folder and a yml file to run. Ex: ./configure_epad.sh ../epad_lite_dist ./epad.yml"
    exit 1
fi
# read yml file and create environment variables
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./yaml.sh
parse_yaml $2 > .env
create_variables $2

if [ -d "./$1" ]
then
    echo "$1 folder already exists. Do you want to replace the $1 installation with the new files? This will cause configurations to be resetted. "
    read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        rm -rf ./$1
    else
        exit 1
    fi
fi

mkdir $1
cp -R ./.originals/* ./$1/.
cp ./epaddb_nodata.sql ./$1/.
cat ./$1/docker-compose_start.ymlpart > ./$1/docker-compose.yml
cat ./$1/nginx_start.confpart > ./$1/nginx.conf
if [ $epadjs_mode != 'external' ]
then
    if [[ ! -z $epadjs_dockerfiledir ]]
    then
        cat ./$1/docker-compose_epadjs_build.ymlpart >> ./$1/docker-compose.yml
    else        
        cat ./$1/docker-compose_epadjs.ymlpart >> ./$1/docker-compose.yml
    fi
fi
if [ $keycloak_mode != 'external' ]
then
    if [[ ! -z $keycloak_loc ]]
    then 
        cat ./$1/nginx_keycloak.confpart >> ./$1/nginx.conf
    fi
    if [[ ! -z $keycloak_dockerfiledir ]]
    then
        cat ./$1/docker-compose_keycloak_build.ymlpart >> ./$1/docker-compose.yml
    else
        cat ./$1/docker-compose_keycloak.ymlpart >> ./$1/docker-compose.yml
    fi
fi
if [ $couchdb_mode != 'external' ]
then
    if [[ ! -z $couchdb_loc ]]
    then 
        cat ./$1/nginx_couchdb.confpart >> ./$1/nginx.conf
    fi
    cat ./$1/docker-compose_couchdb.ymlpart >> ./$1/docker-compose.yml
fi
if [ $mariadb_mode != 'external' ]
then
    if [[ ! -z $mariadb_loc ]]
    then 
        cat ./$1/nginx_mariadb.confpart >> ./$1/nginx.conf
    fi
    cat ./$1/docker-compose_mariadb.ymlpart >> ./$1/docker-compose.yml
fi
if [ $dicomweb_mode != 'external' ]
then
    if [[ ! -z $dicomweb_loc ]]
    then 
        cat ./$1/nginx_dicomweb.confpart >> ./$1/nginx.conf
    fi
    if [[ ! -z $dicomweb_dockerfiledir ]]
    then
        cat ./$1/docker-compose_dicomweb_build.ymlpart >> ./$1/docker-compose.yml
    else        
        cat ./$1/docker-compose_dicomweb.ymlpart >> ./$1/docker-compose.yml
    fi
fi
if [ $epadlite_mode != 'external' ]
then
    if [[ ! -z $epadlite_loc ]]
    then 
        cat ./$1/nginx_epadlite.confpart >> ./$1/nginx.conf
    fi
    if [[ ! -z $epadlite_dockerfiledir ]]
    then
        cat ./$1/docker-compose_epadlite_build.ymlpart >> ./$1/docker-compose.yml
    else    
        cat ./$1/docker-compose_epadlite.ymlpart >> ./$1/docker-compose.yml
    fi
fi
cat ./$1/docker-compose_end.ymlpart >> ./$1/docker-compose.yml
cat ./$1/nginx_end.confpart >> ./$1/nginx.conf

rm ./$1/*.ymlpart
rm ./$1/*.confpart


# update for externals
if [ $keycloak_mode == 'external' ]
then
    replace_in_files "{host}\/{keycloak_loc}" "{keycloak_uri}" $1
fi
if [ $couchdb_mode == 'external' ]
then
    echo "External couchdb is not supported for now"
fi
if [ $mariadb_mode == 'external' ]
then
    echo "External mariadb is not supported for now"
fi
if [ $dicomweb_mode == 'external' ]
then
    replace_in_files "{host}\/{dicomweb_loc}" "{dicomweb_uri}" $1
    replace_in_files "epad_dicomweb:8090\/{dicomweb_loc}" "{dicomweb_uri}" $1
fi
if [ $epadlite_mode == 'external' ]
then
   echo "External api is not supported for now"
fi

if [[ ! -z $epadlite_branch && $epadlite_mode == 'build' ]]
then
    replace_in_files "git clone" "git clone -b $epadlite_branch" "$1/epadlite"
fi

if [[ ! -z $dicomweb_branch && $dicomweb_mode == 'build' ]]
then
    replace_in_files "git clone" "git clone -b $dicomweb_branch" "$1/dicomweb-server"
fi

if [[ ! -z $epadjs_branch && $epadjs_mode == 'build' ]]
then
    replace_in_files "git clone" "git clone -b $epadjs_branch" "$1/epadjs"
fi

while read -r line 
do 
    IFS='=' # delimeter
    read -ra ENV <<< "$line" 
    replace_in_files "{${ENV[0]}}" ${ENV[1]} $1
    
done < .env
IFS=' ' 






