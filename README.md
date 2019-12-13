# Distribution files and configuration automation tool for ePad

ePad is designed in a modular structure which runs six sub-modules (docker containers) which can be plugged and unplugged for specific usecases. Each sub-module has its own setting files that can be edited. This tool enables users to use one yml file to populate all configuration files with specific setting for their system.

Update the epad.yml file according to your needs and run 
  ./configure_epad.sh PATH YML_PATH
for generating the configuration files and docker-compose.yml

# epad.yml file

    host: YOUR_HOSTNAME                     # put your public hostname/ip or local sharing name for macs
    mode: lite
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
      image: latest
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
    epadlite:
      mode: build
      dockerfiledir: ".\/epadlite"
      port: 8080
      dbname: epadlite
      log: true
      https: false
      auth: auth
      loc: "api"
    epadjs:
      mode: build
      dockerfiledir: ".\/epadjs"
      port: 80
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
  
  
 
  
