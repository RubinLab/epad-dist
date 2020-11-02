# Distribution files and configuration automation tool for ePad

ePad is designed in a modular structure which runs six sub-modules (docker containers) which can be plugged and unplugged for specific usecases. Each sub-module has its own setting files that can be edited. This tool enables users to use one yml file to populate all configuration files with specific setting for their system.

# System Requirements

    Ram: Min 4gb 
    git needs to be installed
    docker needs to be installed
    docker-compose needs to be installed 

Update the epad.yml file according to your needs and run 
  ./configure_epad.sh PATH YML_PATH
for generating the configuration files and docker-compose.yml
    
# epad.yml file

    host: YOUR_HOSTNAME                     # put your public hostname/ip or local sharing name for macs
    mode: lite
    config: environment                     # defines if settings will be written in physical files or to environment variables 
    cache:                                  # cahce section added in v0.4 version
      size: "10g"
      inactivetime: "60mb"
    compression:                            # compression section added in v0.4 version
      minsize: "20"
    keycloak:
      mode: build                           # possible modes are build, image, external*
      dockerfiledir: ".\/keycloak"
      user: YOUR_KEYCLOAK_ADMIN_USER        # define your keycloak admin username (admin user can manage realm and add/remove users)
      password: YOUR_KEYCLOAK_ADMIN_PASS    # define your keycloak admin password 
      email: YOUR_KEYCLOAK_ADMIN_EMAIL      # define your keycloak admin email
      port: 8899
      loc: "keycloak"                       # defines the nginx location to be served
    couchdb:
      mode: image
      image: "ibmcom\/couchdb3:latest"      # in v0.4 version default value switched from latest to ibmcom/couchdb3 
      user: YOUR_COUCH_ADMIN_USER           # added in v0.4 version define your couchdb admin username
      password: YOUR_COUCH_ADMIN_PASS       # added in v0.4 version efine your couchdb admin password
      port: 8888
      dblocation: "..\/couchdbloc"          # define relative location to where you want to put the couchdb files
    dicomweb:
      mode: build
      dockerfiledir: ".\/dicomweb-server"
      port: 8090
      dbname: chronicle
      log: true
      auth: none
      loc: "pacs"
      branch: "master"                      # defines the branch which will be pulled from guthub for dicomweb project.
    epadlite:
      mode: build
      dockerfiledir: ".\/epadlite"
      port: 8080
      dbname: epadlite
      log: true
      https: false
      auth: auth
      loc: "api"
      branch: "master"                      # defines the branch which will be pulled from guthub for epadlite project.
    epadjs:
      mode: build
      dockerfiledir: ".\/epadjs"
      port: 80
      branch: "master"                      # defines the branch which will be pulled from guthub for epadjs project.
    mariadb:
      mode: image
      image: latest
      dbname: epaddb
      user: YOUR_DB_USER                      # define your mariadb username
      pass: YOUR_DB_PASS                      # define your mariadb password
      rootpass: YOUR_DB_ROOT_PASS             # define your mariadb root password
      port: 3306
      log: false
      backuploc: ".\/epaddb_nodata.sql"
      dblocation: "..\/mariadbloc"            # define relative location to where you want to put the mariadb files

> **Possible modes for each module are build, image, external*
> * build mode requires dockerfiledir to fnd to Dockerfile, 
> * image mode requires a image value to specify the image tag, 
> * external mode requires a uri value to put in the configuration files and excludes component from docker-compose and nginx configuration/

> The command
  `./configure_epad.sh ../epad_lite_dist ./epad.yml`
will generate a file structure like following under ../epad_lite_dist


    ../epad_lite_dist
    ├── dicomweb-server
    │   ├── Dockerfile
    ├── docker-compose.yml                    # docker-compose file
    ├── epadjs
    │   ├── Dockerfile
    ├── epadlite
    │   ├── Dockerfile
    ├── keycloak
    │   ├── Dockerfile
    ├── nginx.conf                            # nginx configuration file
    ├── production_dicomweb.js                # dicomweb-server settings
    ├── production_keycloak.json              # ePad frontend's keycloak setting
    ├── production_epadjs.json                # epad frontend settings
    ├── production_epadlite.js                # ePad backend settings
    ├── production_epadlite_auth.json         # ePad backend's keycloak setting
    ├── production_epadlite_dicomweb.json     # ePad backend's dicomweb setting
    ├── realm-export.json                     # keycloak realm file for dicomweb authentication
    ├── realm-export_epad.json                # keycloak realm file for ePad authentication
    └── terms.ftl                             # terms and conditions for ePad


You can then start ePad with `docker-compose up -d in ../epad_lite_dist` directory.
ePad will be served from the port 80 of the host address specified in epad.yml file

After starting ePad by using docker-compose up -d you will have additional folders for plugins
and a tmp folder which will be used to export and import keycoak users. These folder can be found in the same folder where you see 
epad-dist folder.

Please change the folder rights to public for tmp and pluginData folders. (to change folder rights you can use: chmod 777 tmp )

# Installation Script:
Starting from v0.4 version epad-dist folder contains epad_manage.sh script. This script is designed to make ePad installation, update, start, stop, export/import keycloak users easier. IMPORTANT: If your ePad holds crucial patient data don't use epad_manage.sh script to update your ePad since the epad_manage.sh script is still in the experimental phase. You can download the script and the extensive guide from epad.stanford.edu webpage under download section.

- If you will use epad_manage.sh script and if you have it (in epad-dist) with epad-dist folder you need to move epad_manage.sh file out of the epad-dist folder.
    script usage:
    ./epad_manage.sh install
    
- If you will use epad_manage.sh script you don't need to download ePadlite. The script will download ePadlite and will guide you through the installation.

- Installation script requires git , docker, and docker-compose to be installed on your device.

Notes:
  - DO NOT alter files in the .originals folder
  - You need to make sure the firewall in the machine ePad is installed has port 80 open.


        For centos:
          edit /etc/firewalld/zones/public.xml with sudo privilages
          add: 
            <port protocol="tcp" port="80”/>
          restart firewall with: 
            sudo systemctl restart firewalld
  - There is no upload file size limit, change `client_max_body_size` in nginx.conf if you want to put limitation
  - Access token life span in 15 min, and keycloak ePad realm is configured to run in non ssl mode
  
  
 
  
