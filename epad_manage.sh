#!/bin/bash
# $1 expected install, start, stop, update
# $2 expected a version master,latest,v0.1, v0.2 

var_path=$(pwd)
#echo "epad will be installed in : $var_path"
# sytem configuration variables
	var_version="master"
	var_epadDistLocation="epad-dist"
	var_epadLiteDistLocation="epad_lite_dist"
	var_response=""
	var_host="localhost"
	var_mode="lite" # or thick
	var_config="environment" # or nothing
	var_container_mode="image" # or build
	var_couchdb_location="couchdblocation"
	var_mariadb_location="mariadblocation"
	var_branch="master" # used for epad_lite and epad_js containers

# user name and passwords for containers
	var_keycloak_user="admin"
	var_keycloak_pass="admin"
	var_keycloak_useremail="admin@gmail.com"

	var_maria_user="admin"
	var_maria_pass="admin"
	var_maria_rootpass="admin"

# keycloak eport settings
	# ! keep /tmp/ in case you want to edit the file name epad_realm.josn
	var_keycloak_export="/tmp/epad_realm.json" 
	var_realmName="ePad"
	var_provider="singleFile"

#echo "\$1:$1"
#read -p 'maria pass ? : ' var_response
#echo $var_maria_rootpass

# functions 
	copy_epad_dist (){
		var_response="n"	
		
		if [[ -d "$var_path/$var_epadDistLocation" ]]; then
  			read -p  "epad-dist exist already exist do you want to owerwrite ? (y/n) (defult value is n): " var_response
		else
			cd $var_path
  			git clone -b script https://github.com/RubinLab/epad-dist.git
		fi

		if [[ "$var_response" -eq "y" ]]; then
  			echo "copying epad-dist repo from git"
			rm -rf "$var_path/$var_epadDistLocation"
			cd $var_path
  			git clone -b script https://github.com/RubinLab/epad-dist.git
		fi
	}

	create_epad_lite_dist(){
		var_response="n"
		if [ -d "$var_path/$var_epadLiteDistLocation" ]; then
                        read -p  "epad_lite_dist folder exist already do you want to owerwrite ? (y/n) (defult value is n): " var_response
                else
			cd "$var_path/$var_epadDistLocation"
                        ./configure_epad.sh ../$var_epadLiteDistLocation ./epad.yml
			
                fi

                if [ $var_response == "y" ]; then
                        echo "creating $var_epadLiteDistLocation folder"
                        rm -rf "$var_path/$var_epadLiteDistLocation"
			cd "$var_path/$var_epadDistLocation"
                        ./configure_epad.sh ../$var_epadLiteDistLocation ./epad.yml
                fi

	}

	stop_containers_all (){
		#export_keycloak
		#echo $!
		#result=""

		#while [[ -z $result  ]]; do
		#	result=$(cat exportkeycloak.log | grep "Export finished successfully")
		#done

		#echo $result
		cd "$var_path/$var_epadLiteDistLocation"
		docker-compose stop
		
	}

	start_containers_all (){
		cd "$var_path/$var_epadLiteDistLocation"
                docker-compose start
		linecount=0
		counter=0
		var_waiting="starting epad"
		while [[ "$linecount" -ne "4"  ]]; do
			counter=$((counter+1))
                        linecount=$(docker ps -a  | grep healthy | wc -l)
			if [[ $counter -ge 0 ]]; then
				var_waiting="$var_waiting."
				echo -en "$var_waiting\r"
				sleep 1
			fi	
                        if [[ "$counter" -eq "10" ]]; then
                                echo -en 'starting epad                     \r'
				counter=0
				var_waiting="starting epad"
                        fi
                done
		echo "epad is ready to browse : $var_host"
	
	}

	start_containers_viaCompose_all (){
                cd "$var_path/$var_epadLiteDistLocation"
		ls
                docker-compose up -d
                linecount=0
                counter=0
                var_waiting="starting epad"
                while [[ "$linecount" -ne "4"  ]]; do
                        counter=$((counter+1))
                        linecount=$(docker ps -a  | grep healthy | wc -l)
                        if [[ $counter -ge 0 ]]; then
                                var_waiting="$var_waiting."
                                echo -en "$var_waiting\r"
                                sleep 1
                        fi
                        if [[ "$counter" -eq "10" ]]; then
                                echo -en '                                        \r'
                                counter=0
                                var_waiting="starting epad"
                        fi
                done
                echo "epad is ready to browse: $var_host"

        }


	collect_system_configuration(){
		var_response=""
		
		read -p "hostname (default value : localhost) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_host=$var_response
                        echo "host name : $var_host"
                fi
                
		read -p "mode (default value : $var_mode) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_mode=$var_response
                        echo "mode : $var_mode"
                fi
                
		read -p "confiduration (default value : $var_config) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_config=$var_response
                        echo "config : $var_config"
                fi
		
		read -p "maria db location (default value : $var_mariadb_location) :" var_response
              	if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_mariadb_location=$var_response
                        echo "mariadb_location : $var_mariadb_location"
                fi
		
		read -p "couch db location (default value : $var_couchdb_location) :" var_response
              	if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_couchdb_location=$var_response
                        echo "couchdb location : $var_couchdb_location"
                fi
	}
	
	collect_user_credentials (){
		var_response=""
		
		read -p "keycloak user name (default value : $var_keycloak_user) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_keycloak_user=$var_response
                        echo "var_keycloak_user : $var_keycloak_user"
                fi
		read -sp "keycloak user password (default value : $var_keycloak_pass) :" var_response
		if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_keycloak_pass=$var_response
                        echo "var_keycloak_pass : $var_keycloak_pass"

                fi
		printf '\n'
		read -p "keycloak user email (default value : $var_keycloak_useremail) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_keycloak_useremail=$var_response
                        echo "var_keycloak_useremail : $var_keycloak_useremail"

                fi
		read -p "maria db user name (default value : $var_maria_user) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_maria_user=$var_response
                        echo "var_maria_user : $var_maria_user"

                fi
		read -sp "maria db user password (default value : $var_maria_pass) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_maria_pass=$var_response
                        echo "var_maria_pass : $var_maria_pass"

                fi
		printf '\n'
		echo $var_response
		read -sp "maria db root password (default value : $var_maria_rootpass) :" var_response
                if [[ -n "$var_response" ]]
		then
                        echo "response = $var_response"
                        var_maria_rootpass=$var_response
                        echo "var_maria_rootpass : $var_maria_rootpass"

                fi
		printf '\n'
	}

	edit_epad_yml (){
		sed -i -e "s/host:.*/host: $var_host/g" "$var_epadDistLocation/epad.yml"
		#sed -i -e "s/mode:.*/mode: $var_mode/g" "$var_epadDistLocation/epad.yml"
		awk -v var_awk="mode: $var_mode" '/mode.*/{c++; if (c==1) { sub("mode.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"

		sed -i -e "s/config:.*/config: $var_config/g" "$var_epadDistLocation/epad.yml"
		#sed -i -e "s/user:.*/user: $var_keycloak_user/g" "$var_epadDistLocation/epad.yml"
	        awk -v var_awk="user: $var_keycloak_user" '/user.*/{c++; if (c==1) { sub("user.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"

		sed -i -e "s/password:.*/password: $var_keycloak_pass/g" "$var_epadDistLocation/epad.yml"
                sed -i -e "s/email:.*/email: $var_keycloak_useremail/g" "$var_epadDistLocation/epad.yml"
                #sed -i -e "s/user:.*/user: $var_maria_user/g" "$var_epadDistLocation/epad.yml"
                sed -i -e "s/pass:.*/pass: $var_maria_pass/g" "$var_epadDistLocation/epad.yml"
                sed -i -e "s/rootpass:.*/rootpass: $var_maria_rootpass/g" "$var_epadDistLocation/epad.yml"
		awk -v var_awk="user: $var_maria_user" '/user.*/{c++; if (c==2) { sub("user.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
	}

	import_keycloak(){
		echo "importing keycloak users...."		
		docker exec -i epad_keycloak /opt/jboss/keycloak/bin/standalone.sh \
		-Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=import \
		-Dkeycloak.migration.provider=$var_provider \
		-Dkeycloak.migration.realmName=$var_realmName \
		-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
		-Dkeycloak.migration.file=$var_keycloak_export > importkeycloak.log &
		echo $! > "$var_path/pid.txt"
                echo $!
                result=""

                while [[ -z $result  ]]; do
                        result=$(cat $var_path/exportkeycloak.log | grep "Export finished successfully")
                done

                echo $result


	}

	export_keycloak(){
		echo "eporting keycloak users....\n"
		docker exec -i epad_keycloak /opt/jboss/keycloak/bin/standalone.sh \
		-Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=export \
		-Dkeycloak.migration.provider=$var_provider \
		-Dkeycloak.migration.realmName=$var_realmName \
		-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
		-Dkeycloak.migration.file=$var_keycloak_export  > exportkeycloak.log &
		echo $! > "$var_path/pid.txt"
		echo $!
                result=""

                while [[ -z $result  ]]; do
                        result=$(cat $var_path/exportkeycloak.log | grep "Export finished successfully")
                done

                echo $result



	}
		
	show_instructions(){
                echo "you need to provide arguments "
                echo "script example usage :"
                echo "epad_manage.sh install"
                echo "epad_manage.sh start"
                echo "epad_manage.sh stop"
                echo "epad_manage.sh update v0.1"
                echo "epad_manage.sh update epad verison"
		echo "epad_manage.sh update epad user"
	}

# main 
	if [ "$#" -gt 0 ]; then

		if [[ $1 = "install" ]]; then	
			echo "epad will be installed in : $var_path"
			if [[ -d "$var_path/tmp" ]]; then
				echo "tmp dir exist already"
			else
				mkdir "$var_path/tmp"
				chmod 777 "$var_path/tmp"	
			fi
			#stop_containers_all
			copy_epad_dist
			collect_system_configuration
			collect_user_credentials
			edit_epad_yml
			create_epad_lite_dist
			start_containers_viaCompose_all
			var_check=0
			#while [[ "$var_check" -eq "0" ]]
			#do
			#	if [ -d "$var_path/$var_epadLiteDistLocation" ]; then
	                #		start_containers_viaCompose_all
			#		var_check=1
			#	fi
			#done

		fi

                if [[ $1 = "start" ]]; then
			start_containers_all
                fi

                if [[ $1 = "stop" ]]; then
                        stop_containers_all
                fi
		
		if [[ $1 = "update" ]]; then
                        if [[ $2 = "epad" ]]; then
				echo "update epad"
				export_keycloak
				stop_containers_all
				cd "$var_path/$var_epadLiteDistLocation"
				docker-compose build --no-cache
				start_containers_viaCompose_all
				import_keycloak
			elif [[ $2 = "user" ]]; then
				echo "update user"
			else
				show_instructions
			fi
			
                fi
	else
		show_instructions
	fi
