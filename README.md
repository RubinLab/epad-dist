# Distribution files and configuration automation tool for ePad

ePad is designed in a modular structure which runs six sub-modules (docker containers) which can be plugged and unplugged for specific usecases. Each sub-module has its own setting files that can be edited. This tool enables users to use one yml file to populate all configuration files with specific setting for their system.

Update the epad.yml file according to your needs and run 
  ./configure_epad.sh PATH
for generating the configuration files and docker-compose.yml

The command
  ./configure_epad.sh ../epad_lite_dist
will generate a file structure like following under ../epad_lite_dist
  - dicomweb-server
  --- Dockerfile
  - docker-compose.yml                    # docker-compose file
  - epadjs
  --- Dockerfile
  - epadlite
  --- Dockerfile
  - keycloak
  --- Dockerfile
  - nginx.conf                            # nginx configuration file
  - production_dicomweb.js                # dicomweb-server settings
  - production_keycloak.json              # ePad frontend's keycloak setting
  - production_epadjs.json	              # epad frontend settings
  - production_epadlite.js                # ePad backend settings
  - production_epadlite_auth.json         # ePad backend's keycloak setting
  - production_epadlite_dicomweb.json     # ePad backend's dicomweb setting
  - realm-export.json                     # keycloak realm file for dicomweb authentication
  - realm-export_epad.json	              # keycloak realm file for ePad authentication
  - terms.ftl                             # terms and conditions for ePad


You can then start epad with docker-compose up -d in ../epad_lite_dist directory.
ePad will be served from the port 80 of the host address specified in epad.yml file

Notes:
  - DO NOT alter files in the .originals folder
  - You need to make sure the firewall in the machine ePad is install has port 80 open.
For centos:
  edit: sudo nano /etc/firewalld/zones/public.xml
  add: 
    <port protocol="tcp" port="80”/>
  restart firewall with: 
    sudo systemctl restart firewalld
  
