#!/bin/bash
# $1 expected install, start, stop, update
# $2 expected a version master,latest,v0.1, v0.2 

var_path=$(pwd)
var_os_type=""
#echo "epad will be installed in : $var_path"
# sytem configuration variables
	var_ip=""
	var_local_docker_gid=0
	var_version="master"
	var_epadDistLocation="epad-dist"
	var_epadLiteDistLocation="epad_lite_dist"
	var_response=""
	var_host=""
	var_mode="lite" # or thick
	var_config="environment" # or nothing
	var_container_mode="image" # or build
	var_couchdb_location="..\/couchdbloc"
	var_mariadb_location="..\/mariadbloc"
	var_branch="master" # used for epad_lite and epad_js containers

	var_branch_dicomweb="master" #new
	var_branch_epadlite="master"  #new
	var_branch_epadjs="master"  #new
	
# user name and passwords for containers
	var_keycloak_user="admin"
	var_keycloak_pass="admin"
	var_keycloak_useremail="admin@gmail.com"

	var_maria_user="admin"
	var_maria_pass="admin"
	var_maria_rootpass="admin"

# keycloak eport settings
	# ! keep /tmp/ in case you want to edit the file name epad_realm.josn
	var_keycloak_exportfolder="/tmp/epad_realm.json" 
	var_realmName="ePad"
	var_provider="singleFile"

#echo "\$1:$1"
#read -p 'maria pass ? : ' var_response
#echo $var_maria_rootpass

# functions

		check_container_situation(){
			# local_situation can be these values-> ok, healty , fail 

			local var_total_fail=0
			local var_container_situation=""
			local var_failed_container_names=""
			local var_counter=0

			var_container_situation=$(docker ps -a --filter "name=\bepad_lite\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_lite"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_lite\b" --format "table {{.Status}}" | grep Exited )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi


			var_container_situation=$(docker ps -a --filter "name=\bepad_js\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_js"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_js\b" --format "table {{.Status}}" | grep Exited )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_dicomweb\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_dicomweb"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_dicomweb\b" --format "table {{.Status}}" | grep Exited )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_keycloak"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}" | grep Exited )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_couchdb"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Status}}" | grep Exited )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_mariadb\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_mariadb"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_mariadb\b" --format "table {{.Status}}" | grep Exited )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			# docker ps -a -f status=exited | grep "\bepad_lite\b"
			# echo $var_total_fail

			if [[ $var_total_fail > 0 ]]; then
				echo "there are failed containers"
				var_counter=$(docker ps -a -f 'status=exited' |  wc -l)
				if [[ $var_counter > 1 ]]; then
					docker ps -a -f 'status=exited'
				fi
				echo "Please contact epad team!"
				if [[ "$var_failed_container_names" != "" ]]; then
					echo "ePad couldn't find following containers : $var_failed_container_names "
				fi
				exit 1
			fi

		}

		check_keycloak_container_situation(){
			local var_container_situation=""
			var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				echo "container epad_keycloak does not exist. Please start epad first "
				exit 1
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}" | grep Up )
				if [[  -z $var_container_situation ]]; then
					echo "container epad_keycloak is not running. Please start epad first "
					exit 1
				fi
			fi
		}

		find_os_type(){
		echo "process: finding os type"
                if [[ $OSTYPE == "linux"* ]]; then
                        var_os_type="linux"
                elif  [[ $OSTYPE == "darwin"* ]]; then
                        var_os_type="mac"
                else
                        echo " your operating system is not supported or ostype env. variable is not defined. Only linux and macs are supported "i
                        exit 1
                fi
        }

        add_backslash_tofolderpath(){
		#$1 is the parameter passed to this function
                #echo "adding backslash"         
		var_tmp_txt=$(echo $1  |  sed 's-/-\\/-g')
		echo $var_tmp_txt 
        }
        remove_backslash_tofolderpath(){	
		#$1 is the parameter passed to this function
                #echo "removing backslash"
                #var_a="\/home\/epad\/epadDistScript\/test\/epad-dist"
                var_tmp_txt=$( echo $1 | tr -d '\\' )
                echo $var_tmp_txt
		#iecho $(echo cavi=/cat  |  sed 's-/-\\/-g')
       }

	find_val_intext(){
		# first param : text : string 
		# second param : occourrence : number
		#echo "finding values"
		#echo "Parameter #1 is $1"
		#echo "Parameter #2 is $2"
		var_tmp_txt=$( awk "/$1/{i++}i==$2{print; exit}"  "$var_path/$var_epadDistLocation/epad.yml")
 		var_tmp_txt=$( echo $var_tmp_txt | cut -d: -f2)
                #hostname loaded from epad.yml to variable
		echo $var_tmp_txt
		#echo "hostname from file :$var_host"
				
	}

	find_ip(){
	#echo "process: finding machine ip "
 		if [[ "$var_os_type" == "linux"* ]]; then
            var_ip=$(hostname -I | cut -d" " -f1)
        else 
			var_ip=$(ifconfig | grep -w inet | cut -d " "  -f2 | tail -1)
		fi
	
		if [[ "$var_ip" == "" ]]; then
			echo "we couldn't find an ip please contact your server admin or epad team"
			exit 1
		fi
		echo $var_ip
	}

	doublecheck_ipmapping_onstart(){
		local var_hostname_from_epadyml=""
		local var_ip_frometc=""
		local var_fresh_ip=""
		var_hostname_from_epadyml=$( find_val_intext "host" "1")
		var_ip_frometc=$( cat /etc/hosts | grep "\b$var_hostname_from_epadyml\b" | awk '{print $1}' )
		# echo $var_ip_frometc
		if [[ ! -z $var_ip_frometc ]]; then
			var_fresh_ip=$(find_ip)
			if [[ $var_ip_frometc != $var_fresh_ip ]]; then
				echo "you need to refresh the ip in /etc/hosts file. Please run the script epad_fixmyip.sh which is located in epad-dist folder. This operation requires sudo right"
				exit 1
			fi
		fi

	}

	find_hostname_from_hostsfile(){
	echo "process: finding machine name from etc/hosts"
		local var_local_servername=""
		var_res=$(find_ip)
		echo $var_res
		var_local_servername=$( cat /etc/hosts | grep $var_res )
		if [ -z "$var_local_servername" ]; then
            echo "could not find your ip in your /etc/hosts file please fix your ip manually or use epad_fixmyip.sh script which is located in your epad-dist folder"
            exit 1
        else
            echo "your ip $var_res found in /etc/hosts file. Collecting server name"
			var_local_servername=$( cat /etc/hosts | grep $var_res | awk '{print $2}' )
			echo $var_local_servername
			if [ -z "$var_local_servername" ]; then
				echo "$var_res ip is not mapped to a name in /etc/hosts file. Your ip will be used as your host name or please fix manually to map your ip to a name or use epad_fixmyip.sh script which is located in epad-dist folder"
				var_host=$var_res
				echo "your host name for epad is set to $var_host"
				
			else

				var_host=$var_local_servername
				echo "$var_res ip is  mapped to $var_host in /etc/hosts file.  ePad will use $var_host "
			fi
        fi
	}
	
	edit_hosts_file(){
	echo "process: editing /etc/hosts"
 		
		var_res=$(cat /etc/hosts | grep $var_ip)
        if [ -z "$var_res" ]; then
            echo "ip not found"
			echo "$var_ip $var_host" >> /etc/hosts
        else
            echo "$var_res is already in etc"
			var_res_epadvm=$( echo $var_res | grep epadvm )
			echo "checking if epadvm is in /etc/hosts "
			echo $var_res_epadvm
			if [ -z "$var_res_epadvm" ]; then
				echo "$var_res : your ip is mapped to a different name"
				var_host=$( echo $var_res | cut -d " " -f2)
				echo "your host name for epad is set to $var_host"
			fi
        fi
		
	}

	fix_server_via_hosts(){
	#echo "process: fixing server hostname via /etc/hosts "
		var_host="epadvm"
		find_ip	
		edit_hosts_file
	#	echo "after fixing etc/hosts $var_host"
		echo $var_host
	}

	find_host_info(){
	#echo "process: finding host info"
	local var_resp
		if [[ $var_host == "" ]];then
			if [[ $HOSTNAME == "" ]];then
				echo "hostname is empty checking etc/hosts file to find server name"
				find_hostname_from_hostsfile
			else
				echo "if you used epad_fixmyip.sh script to fix your server name answer 2 fot he following question!"
				read -p " you have a valid hostname env variable $HOSTNAME.Do you want to use this (1) or do you want to grap hostname by using /etc/hosts (2) ? ( 1 or 2 ) : " var_resp
                if [[ $var_resp == 1 ]]; then
					var_host=$HOSTNAME
				else
					find_hostname_from_hostsfile
				fi
			fi
		fi
	}

	load_credentials_tovar (){
	echo "process: loading credentials from epad.yml to variables for a new epad.yml"

		echo $var_path
		#var_tmp_txt=""
		#var_tmp_txt=$( awk '/host/{i++}i==1{print; exit}'  "$var_path/$var_epadDistLocation/epad.yml")
		#var_host=$( echo $var_tmp_txt | cut -d: -f2)
		#var_host=$( find_val_intext "host" "1")

		var_mode=$( find_val_intext "mode" "1")
        var_config=$( find_val_intext "config" "1")
        #var_container_mode==$( find_val_intext "host" "1")
        var_couchdb_location=$( find_val_intext "dblocation" "1")
		var_couchdb_location=$(echo $var_couchdb_location | sed 's/"//g')
        var_mariadb_location=$( find_val_intext "dblocation" "2")
        var_mariadb_location=$(echo $var_mariadb_location | sed 's/"//g')
        
        var_keycloak_user=$( find_val_intext "user" "1")
        var_keycloak_pass=$( find_val_intext "password" "1")
        var_keycloak_useremail=$( find_val_intext "email" "1")

        var_maria_user=$( find_val_intext "user" "2")
        var_maria_pass=$( find_val_intext "pass" "2")
        var_maria_rootpass=$( find_val_intext "rootpass" "1")

        var_branch_dicomweb=$( find_val_intext "branch" "1")
        var_branch_dicomweb=$(echo $var_branch_dicomweb | sed 's/"//g')

        var_branch_epadlite=$( find_val_intext "branch" "2")
        var_branch_epadlite=$(echo $var_branch_epadlite | sed 's/"//g')

        var_branch_epadjs=$( find_val_intext "branch" "3")
        var_branch_epadjs=$(echo $var_branch_epadjs | sed 's/"//g')

		# echo "loaded variables from epad.yml : ++++++++++++++++ "
		# echo " var_host :$var_host"
	 #    echo " var_mode :$var_mode"
	 #    echo " var_config :$var_config"
	 #    echo " var_container_mode:$var_container_mode"
	 #    echo " var_couchdb_location:$var_couchdb_location"
	 #    echo " var_mariadb_location:$var_mariadb_location"
	 #    echo " var_branch:$var_branch"
	    
	            
	 #    echo " var_keycloak_user:$var_keycloak_user"
	 #    echo " var_keycloak_pass:$var_keycloak_pass"
	 #    echo " var_keycloak_useremail:$var_keycloak_useremail"

	 #    echo " var_maria_user:$var_maria_user"
	 #    echo " var_maria_pass:$var_maria_pass"
	 #    echo " var_maria_rootpass:$var_maria_rootpass"

	 #    echo "  dicomweb branch: $var_branch_dicomweb"
	 #    echo "  epadlite branch: $var_branch_epadlite"
	 #    echo "  epadjs branch: $var_branch_epadjs"
	} 
	
	find_docker_gid(){
	echo "process: finding docker group id"
		var_local_docker_gid=$( cat /etc/group | grep docker | cut -d: -f3)
		echo "gid : $var_local_docker_gid"
	}

	copy_epad_dist (){
	echo "process: copying epad-dist from git.."
		var_response="n"	
		
		if [[ -d "$var_path/$var_epadDistLocation" ]]; then
			load_credentials_tovar
  			read -p  "epad-dist folder exist already. Do you want to owerwrite ? (y/n) (defult value is n): " var_response
		else
			cd $var_path
  			git clone -b script https://github.com/RubinLab/epad-dist.git
		fi

		if [[ $var_response == "y" ]]; then
  			echo "copying epad-dist repo from git"
			rm -rf "$var_path/$var_epadDistLocation"
			cd $var_path
  			git clone -b script https://github.com/RubinLab/epad-dist.git
		fi
	}

	create_epad_lite_dist(){
	echo "process: building epad_lite_dist from epad.yml"
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
	echo "process: stopping all containers..."
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
	echo "process: starting all containers..."

	local var_start=$(date +%s)
	local var_end=$(($var_start + 300))
	#echo $var_start
	#echo $var_end
		cd "$var_path/$var_epadLiteDistLocation"
        docker-compose start
		linecount=0
		counter=0
		var_waiting="starting epad"
		while [[ $linecount -lt 4 && $var_start -lt $var_end ]]; do
			var_start=$(date +%s)
				counter=$((counter+1))
	            linecount=$(docker ps -a  | grep healthy | wc -l)
				if [[ $counter > 0 ]]; then
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
        linecount=$(docker ps -a  | grep healthy | wc -l)
        if [[ $linecount -lt 4 ]]; then
        	echo "one or more container have issues. ePad couldn't start"
        else
        	echo "epad is ready to browse: $var_host"
        fi
	
	}

	start_containers_viaCompose_all (){
	echo "process: starting all containers using docker-compose up -d"

	local var_start=$(date +%s)
	local var_end=$(($var_start + 300))
	#echo $var_start
	#echo $var_end
           		cd "$var_path/$var_epadLiteDistLocation"
                docker-compose up -d
                linecount=0
                counter=0
                var_waiting="starting epad"
                while [[ $linecount -lt 4 && $var_start -lt $var_end ]]; do
                	var_start=$(date +%s)
                        counter=$((counter+1))
                        linecount=$(docker ps -a  | grep healthy | wc -l)
                        if [[ $counter > 0 ]]; then
                                var_waiting="$var_waiting."
                                echo -en "$var_waiting\r"
                                sleep 1
                        fi
                        if [[ $counter == 10 ]]; then
                                echo -en '                                        \r'
                                counter=0
                                var_waiting="starting epad"
                        fi
                done
                linecount=$(docker ps -a  | grep healthy | wc -l)
                if [[ $linecount -lt 4 ]]; then
                	echo "one or more container have issues. ePad couldn't start"
                else
                	echo "epad is ready to browse: $var_host"
                fi

        }


	collect_system_configuration(){
	echo "process: collecting system configuration info"
		var_response=""
		
		read -p "hostname (default value : $var_host) :" var_response
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
        # branch section

        		read -p "dicomweb branch: (default value : $var_branch_dicomweb) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_branch_dicomweb=$var_response
                        echo "dicomweb branch : $var_branch_dicomweb"
                fi
        		
        		read -p "epadlite branch: (default value : $var_branch_epadlite) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_branch_epadlite=$var_response
                        echo "epadlite branch : $var_branch_epadlite"
                fi
        		
        		read -p "epadjs branch: (default value : $var_branch_epadjs) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_branch_epadjs=$var_response
                        echo "epadjs branch : $var_branch_epadjs"
                fi
        # branch section
                
		read -p "confiduration (default value : $var_config) :" var_response
                if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_config=$var_response
                        echo "config : $var_config"
                fi
		
		read -p "maria db location (default value : $( remove_backslash_tofolderpath $var_mariadb_location)) :" var_response
              	if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_mariadb_location=$( add_backslash_tofolderpath $var_response)  
                        echo "mariadb_location : $( remove_backslash_tofolderpath $var_mariadb_location) "
                fi
		
		read -p "couch db location (default value :  $( remove_backslash_tofolderpath $var_couchdb_location)) :" var_response
              	if [[ -n "$var_response" ]]
                then
                        echo "response = $var_response"
                        var_couchdb_location=$( add_backslash_tofolderpath $var_response)
                        echo "couchdb location :  $( remove_backslash_tofolderpath $var_couchdb_location) "
                fi
	}
	
	collect_user_credentials (){
	echo "process: collecting user credentials"
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
	echo "process: editing epad.yml file"
		sed -i -e "s/host:.*/host: $var_host/g" "$var_path/$var_epadDistLocation/epad.yml"
		#sed -i -e "s/mode:.*/mode: $var_mode/g" "$var_path/$var_epadDistLocation/epad.yml"
		awk -v var_awk="mode: $var_mode" '/mode.*/{c++; if (c==1) { sub("mode.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"

		sed -i -e "s/config:.*/config: $var_config/g" "$var_path/$var_epadDistLocation/epad.yml"
		#sed -i -e "s/user:.*/user: $var_keycloak_user/g" "$var_path/$var_epadDistLocation/epad.yml"
	        awk -v var_awk="user: $var_keycloak_user" '/user.*/{c++; if (c==1) { sub("user.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"

		sed -i -e "s/password:.*/password: $var_keycloak_pass/g" "$var_path/$var_epadDistLocation/epad.yml"
        sed -i -e "s/email:.*/email: $var_keycloak_useremail/g" "$var_path/$var_epadDistLocation/epad.yml"
        #sed -i -e "s/user:.*/user: $var_maria_user/g" "$var_path/$var_epadDistLocation/epad.yml"
        sed -i -e "s/pass:.*/pass: $var_maria_pass/g" "$var_path/$var_epadDistLocation/epad.yml"
        sed -i -e "s/rootpass:.*/rootpass: $var_maria_rootpass/g" "$var_path/$var_epadDistLocation/epad.yml"
		awk -v var_awk="user: $var_maria_user" '/user.*/{c++; if (c==2) { sub("user.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
	
		#sed -i -e "s/ARG_EPAD_DOCKER_GID:.*/ARG_EPAD_DOCKER_GID: $var_local_docker_gid/g" "var_path/$var_epadLiteDistLocation/docker-compose.yml"
		
		#setup dblocations
		
		temp_var_mariadb_location=$( add_backslash_tofolderpath $var_mariadb_location) 
		
        awk -v var_awk="dblocation: \"$temp_var_mariadb_location\" " '/dblocation.*/{c++; if (c==2) { sub("dblocation.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"

        temp_var_couchdb_location=$( add_backslash_tofolderpath $var_couchdb_location)
                
        awk -v var_awk="dblocation: \"$temp_var_couchdb_location\" " '/dblocation.*/{c++; if (c==1) { sub("dblocation.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
	
        # edit branch part
        awk -v var_awk="branch: \"$var_branch_dicomweb\"" '/branch.*/{c++; if (c==1) { sub("branch.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
        awk -v var_awk="branch: \"$var_branch_epadlite\"" '/branch.*/{c++; if (c==2) { sub("branch.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
        awk -v var_awk="branch: \"$var_branch_epadjs\"" '/branch.*/{c++; if (c==3) { sub("branch.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
        #edit branch part end
	}

	edit_compose_file(){
	echo "process: editing docker-compose file for ARG_EPAD_DOCKER_GID"
		sed -i -e "s/ARG_EPAD_DOCKER_GID:.*/ARG_EPAD_DOCKER_GID: $var_local_docker_gid/g" "$var_path/$var_epadLiteDistLocation/docker-compose.yml"
	}


	import_keycloak(){
		echo "process: importing keycloak users...."
		check_keycloak_container_situation
		var_full_keycloak_export_path=$var_path$var_keycloak_exportfolder
		if [ ! -f "$var_full_keycloak_export_path" ]; then
			echo "$var_full_keycloak_export_path does not exist. You need to export keycloak users first."
			exit 1
		fi
		echo $var_full_keycloak_export_path
		#var_import_process=$(docker container top epad_keycloak | grep "keycloak.migration.action" | cut -d" " -f1)
		#echo "$var_import_process"
		#echo "importing keycloak users...."		
		docker exec -i epad_keycloak /opt/jboss/keycloak/bin/standalone.sh \
		-Djboss.socket.binding.port-offset=200 -Dkeycloak.migration.action=import \
		-Dkeycloak.migration.provider=$var_provider \
		-Dkeycloak.migration.realmName=$var_realmName \
		-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
		-Dkeycloak.migration.file=$var_keycloak_exportfolder > importkeycloak.log &
		#echo $! > "$var_path/pid.txt"
                #echo $!
                result=""
                resultFail=""
                while [[ -z $result ]] && [[ -z $resultFail ]]; do
                        result=$(cat $var_path/importkeycloak.log | grep "Import finished successfully")

                        resultFail=$(cat $var_path/importkeycloak.log | grep "Server boot has failed in an unrecoverable manner")
                done

                echo $result
                if [[ $resultFail == *"Server boot has failed in an unrecoverable manner"* ]]; then
                        echo "$resultFail.  Exiting script...."         
                        exit 1
                fi
		echo "restarting keycloak"
		docker restart epad_keycloak

	}

	export_keycloak(){
	 
		echo "process: exporting keycloak users....\n"
		check_keycloak_container_situation
		docker exec -i epad_keycloak /opt/jboss/keycloak/bin/standalone.sh \
		-Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=export \
		-Dkeycloak.migration.provider=$var_provider \
		-Dkeycloak.migration.realmName=$var_realmName \
		-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
		-Dkeycloak.migration.file=$var_keycloak_exportfolder  > exportkeycloak.log &
		#echo $! > "$var_path/pid.txt"
		#echo $!
                result=""
                resultFail=""
                while [[ -z $result ]] && [[ -z $resultFail ]]; do
                        result=$(cat $var_path/exportkeycloak.log | grep "Export finished successfully")

                        resultFail=$(cat $var_path/exportkeycloak.log | grep "Server boot has failed in an unrecoverable manner")
                done

                echo $result
                if [[ $resultFail == *"Server boot has failed in an unrecoverable manner"* ]]; then
                        echo "$resultFail.  Exiting script...."         
                        exit 1
                fi
		echo "restarting keycloak"
                docker restart epad_keycloak

	}
		
	show_instructions(){
        echo "you need to provide argument(s) "
        echo "script comands :"

        echo "epad_manage.sh install"
        echo "epad_manage.sh start"
        echo "epad_manage.sh stop"

        echo "epad_manage.sh update epad"
		echo "epad_manage.sh update config"
		#echo "epad_manage.sh fixip"

		echo "epad_manage.sh export keycloakusers"
		echo "epad_manage.sh import keycloakusers"
	}

# main 
	if [ "$#" -gt 0 ]; then


         if [[ $1 == "test" ]]; then
			
			echo "test started ----------------------------"
			doublecheck_ipmapping_onstart
			echo "test ended ----------------------------"

		 fi

		if [[ $1 == "install" ]]; then	
			
			echo "epad will be installed in : $var_path"
				# below commented section is for creation of tmp folder to inport/export keycloak users 
				# if [[ -d "$var_path/tmp" ]]; then
				# 	echo "tmp dir exist already"
				# else
				# 	mkdir "$var_path/tmp"
				# 	chmod 777 "$var_path/tmp"	
				# fi
			#stop_containers_all
			copy_epad_dist
			find_host_info
			# commented section below is for fixing ip automatically 
			# var_install_response="n"
			# if [[ $var_host == "" ]]; then
			# 	read -p " your machine hostname is empty do you want us to fix it ? (y/n default value is n) : " var_install_response
			 	
			# 	if [[ $var_install_response == "y" ]]; then
			# 		fix_server_via_hosts
			# 	fi

			# fi
			find_docker_gid
			collect_system_configuration
			collect_user_credentials
			edit_epad_yml
			create_epad_lite_dist
			edit_compose_file
			start_containers_viaCompose_all
			check_container_situation

		fi

        if [[ $1 == "start" ]]; then
			#load_credentials_tovar
			var_host=$( find_val_intext "host" "1")
			doublecheck_ipmapping_onstart
			start_containers_all
			check_container_situation
        fi

        if [[ $1 == "stop" ]]; then
            stop_containers_all
        fi
 		
		if [[ $1 == "fixip" ]]; then
    		
		    		stop_containers_all
					load_credentials_tovar
					find_host_info
					find_docker_gid
					fix_server_via_hosts
					edit_epad_yml
					create_epad_lite_dist
					edit_compose_file
					start_containers_viaCompose_all
        fi
		
		if [[ $1 == "update" ]]; then
            
            if [[ $2 == "epad" ]]; then
				echo "updating epad"
				export_keycloak
				stop_containers_all
				cd "$var_path/$var_epadLiteDistLocation"
				docker-compose build --no-cache
				start_containers_viaCompose_all
				import_keycloak
				check_container_situation
			elif [[ $2 == "config" ]]; then
				echo "updating epad configuration "
				stop_containers_all
				load_credentials_tovar
				#find_host_info
				#find_docker_gid
                collect_system_configuration
                collect_user_credentials
                edit_epad_yml
                create_epad_lite_dist
				edit_compose_file
				start_containers_viaCompose_all
				check_container_situation
			else
				show_instructions
			fi
			
       	fi
# export import keycloak part
		if [[ $1 == "export" ]]; then
               
                if [[ $2 == "keycloakusers" ]]; then
                        export_keycloak
                fi

         fi

        if [[ $1 = "import" ]]; then
                    
                if [[ $2 == "keycloakusers" ]]; then
                        import_keycloak
                fi

        fi
# epxport import keycloak part end


	else
		show_instructions
	fi
