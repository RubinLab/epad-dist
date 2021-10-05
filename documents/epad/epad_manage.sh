#!/bin/bash
# $1 expected install, start, stop, update
# $2 expected a version master,latest,v0.1, v0.2 
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
Color_Off='\033[0m'
var_global_response=""
var_global_specialchar_flag=""
var_path=$(pwd)
var_os_type=""
global_var_container_exist=""
var_reinstalling="false"
dokcerprocessrsult_formariacredentials=()
var_array_allEpadContainerNames=(epad_lite epad_js epad_dicomweb epad_keycloak epad_couchdb epad_mariadb)
#echo "epad will be installed in : $var_path"
# sytem configuration variables
	var_ip=""
	var_local_docker_gid=999
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
	var_keycloak_port=8899

	var_maria_user="admin"
	var_maria_pass="admin"
	var_maria_rootpass="admin"
	var_maria_port=3306

	var_maria_rootpass_old=""
	var_maria_user_old=""
	var_maria_user_pass_old=""

# keycloak eport settings
	# ! keep /tmp/ in case you want to edit the file name epad_realm.josn
	var_keycloak_exportfolder="/tmp/epad_realm.json" 
	var_realmName="ePad"
	var_provider="singleFile"


	var_couchdb_user="admin"
	var_couchdb_pass="admin"
	var_couchdb_port=8888

	var_dicomweb_port=8090

	var_epadlite_port=8080

	var_epadjs_port=80


	var_specialchar_flag=""
# functions
		handle_errors(){
			# takes 3 params $1 $2 $3 
			# $1 error value ($?) 
			# $2 script needs exit or not (noexit (""), exit) 
			# $3 message to explain, or instructions to the user or just print empty string "" 

			if [[ $? > $1 ]]; then
				if [[ -n $3 ]]; then
   					echo $3
   					echo -e "${Purple}$3"
					echo -e "${Color_Off}"
   				fi

   				if [[ $2 == "exit" ]]; then
   					exit 1
   				fi
   				
			fi
		}

		create_epad_folders(){
			local localvar_couchdbloc=""
			local localvar_folderrights=""
			local localvar_errcnt=0
		    echo -e "${Yellow}process: creating ePad Folders for couchdb, pluginData, tmp, data"
			echo -e "${Color_Off}" 
			find_os_type

			if [[ "$var_os_type" == "linux" ]]; then
					# in linux needs sudo rights let to the user to edit the folder rights
					echo $var_path
					cd $var_path
					if [[ ! -d pluginData ]]; then
						echo "pluginData not found. Creating"
						mkdir "pluginData"
						handle_errors $? "" "Creating pluginData folder failed. You may need sudo right."
						chmod 777 "pluginData"
						handle_errors $? "" "Giving public rights(777) to pluginData failed. You may need sudo right."

					else
						echo "folder found:pluginData"
						localvar_folderrights=$(ls -ld "pluginData" | cut -d" " -f1 | cut -c 8,9,10)
						if [[ $localvar_folderrights != "rwx" ]]; then
			 
							echo -e "${Purple}You need to give public rights(777) manually to pluginData folder in $var_path and then retry installing ePad"
							echo -e "${Color_Off}"
							localvar_errcnt=$(($localvar_errcnt + 1))
						fi

					fi

					if [[ ! -d tmp ]]; then
						echo "tmp folder not found. Creating"
						mkdir "tmp"
						handle_errors $? "" "Creating tmp folder failed. You may need sudo right."
						chmod 777 "tmp"
						handle_errors $? "" "Giving public rights(777) to tmp folder failed. You may need sudo right."

					else
						echo "folder found:tmp"
						localvar_folderrights=$(ls -ld "tmp" | cut -d" " -f1 | cut -c 8,9,10)
						if [[ $localvar_folderrights != "rwx" ]]; then
							echo -e "${Purple}You need to give public rights(777) manually to tmp folder in $var_path and then retry installing ePad"
							echo -e "${Color_Off}"
							localvar_errcnt=$(($localvar_errcnt + 1))
						fi
					fi

					if [[ ! -d data ]]; then
						echo "data folder not found. Creating"
						mkdir "data"
						handle_errors $? "" "Creating data folder failed. You may need sudo right."
						chmod 777 "data"
						handle_errors $? "" "Giving public rights(777) to data folder failed. You may need sudo right."

					else
						echo "folder found:data"
						localvar_folderrights=$(ls -ld "data" | cut -d" " -f1 | cut -c 8,9,10)
						if [[ $localvar_folderrights != "rwx" ]]; then
							echo -e "${Purple}You need to give public rights(777) manually to data folder in $var_path and then retry installing ePad"
							echo -e "${Color_Off}"
							localvar_errcnt=$(($localvar_errcnt + 1))
						fi
					fi

					parse_yml_sections
					localvar_couchdbloc=$(find_val_fromsections "couchdb" "dblocation" | sed 's/"//g' )
					localvar_couchdbloca=$( remove_backslash_tofolderpath $localvar_couchdbloc)
					
					cd "$var_path/$var_epadDistLocation"
					if [[ ! -d "$localvar_couchdbloca" ]]; then
						echo "$localvar_couchdbloca folder not found. Creating"
						mkdir "$localvar_couchdbloca"
						handle_errors $? "" "Creating $localvar_couchdbloca folder failed. You may need sudo right."
						chmod 777 "$localvar_couchdbloca"
						handle_errors $? "" "Giving public rights(777) to $localvar_couchdbloca folder failed. You may need sudo right."

					else
						echo "folder found:$localvar_couchdbloca"
						localvar_folderrights=$(ls -ld "$localvar_couchdbloca" | cut -d" " -f1 | cut -c 8,9,10)
						if [[ $localvar_folderrights != "rwx" ]]; then
							echo -e "${Purple}You need to give public rights(777) manually to $localvar_couchdbloca folder and then retry installing ePad"
							echo -e "${Color_Off}"
							localvar_errcnt=$(($localvar_errcnt + 1))
						fi
					fi

					if [[ $localvar_errcnt > 0 ]]; then
						echo "exiting operation."
						exit 1
					fi
			elif [[ "$var_os_type" == "mac" ]]; then
				echo "process: folder validation result : No need to create folders for macs. Docker will create."
			else
				echo -e "${Purple}Unsupported operating system. Please contact ePad Team if you encounter issues."
				echo -e "${Color_Off}"
			fi 

		}

		check_epadyml_needs_update(){
			local localvar_actual_yml=""
			local localvar_latest_yml=""
			local localvar_counter=0
			local localvar_result=0
			if [[ -d "$var_path/$var_epadDistLocation" ]]; then
				if [[ -f "$var_path/$var_epadDistLocation/epad.yml" ]]; then
					localvar_actual_yml="$var_path/$var_epadDistLocation/epad.yml"
					#echo "testing value localvar_actual_yml : $localvar_actual_yml"
				else
					echo "error: couldn't find epad.yml file in $var_path/$var_epadDistLocation"
					exit 1
				fi
				#	${my_array[@]}
				#echo "sections : ${var_array_fromyml_seections[@]}"
				#echo "sections : ${var_array_fromyml_couchdb[@]}"
				#echo "var_array_fromyml_seections[@] : $var_array_fromyml_seections[@]"
				for i in ${!var_array_fromyml_seections[@]}; do
						if [[ ${var_array_fromyml_seections[$i]} == "cache" || ${var_array_fromyml_seections[$i]} == "compression" ]]; then
							#echo ${var_array_fromyml_seections[$i]}
							localvar_counter=$(($localvar_counter + 1))
							
						fi
				done

				localvar_result=""
				#echo "result : $localvar_counter"
				if [[ $localvar_counter == 2 ]]; then
					localvar_counter=0
					
					# checking the latest keys for couchdb is in epad.yml 

					for i in ${!var_array_fromyml_couchdb[@]}; do
						if [[ $( echo ${var_array_fromyml_couchdb[$i]} | cut -d":" -f1 ) == "user" || $( echo ${var_array_fromyml_couchdb[$i]} | cut -d":" -f1 ) == "password" ]]; then
							localvar_counter=$(($localvar_counter + 1))
							
						fi
					done
					#echo "result : $localvar_counter"
					if [[ $localvar_counter == 2 ]]; then
						localvar_counter=0
							# checking the latest keys for mariadb is in epad.yml 

							for i in ${!var_array_fromyml_mariadb[@]}; do
								if [[ $( echo ${var_array_fromyml_mariadb[$i]} | cut -d":" -f1 ) == "user" || $( echo ${var_array_fromyml_mariadb[$i]} | cut -d":" -f1 ) == "password" || $( echo ${var_array_fromyml_mariadb[$i]} | cut -d":" -f1 ) == "rootpassword" ]]; then
									localvar_counter=$(($localvar_counter + 1))
									
								fi
							done
							#echo "result : $localvar_counter"
							if [[ $localvar_counter == 3 ]]; then
								localvar_counter=0
								echo "uptodate"
							else
								echo "pull"
							fi
					else
						echo "pull"
					fi
				else
					echo "pull"
				fi


			else
				echo "error: couldn't find a valid $var_epadDistLocation folder in $var_path"
				exit 1
			fi

		}

		parse_yml_sections(){
			var_array_fromyml_seections=()
			var_array_fromyml_keycloak=()
			var_array_fromyml_couchdb=()
			var_array_fromyml_dicomweb=()
			var_array_fromyml_epadlite=()
			var_array_fromyml_epadjs=()
			var_array_fromyml_mariadb=()

			if [[ -d "$var_path/$var_epadDistLocation" ]]; then

				if [[ -f "$var_path/$var_epadDistLocation/epad.yml" ]];then
						local input="$var_path/$var_epadDistLocation/epad.yml"
						if [[ -f "$input" ]]; then
								local section=""
								local response=""
								

								while IFS= read -r line
								do
								  response=$(echo $line | grep ":$")
								  if [ ! -z $response ]; then
								  	#section=$response
								  	section=$(echo $response | cut -d":" -f1)
								  	var_array_fromyml_seections+=($section)
								  #echo "section : $section "
								  
								fi
								#echo "response : $response"
								  # echo "first : $response"
								  if [[ -z $response ]]; then
								  	#eachline=$(echo $line | cut -d":" -f1)
								  	eachline=$(echo $line | sed -e 's/[[:space:]]//g')
								  	#echo "merge : $section-$eachline"
										  	case $section in

										  	keycloak)
										    		#echo -n "keycloak"
										    		var_array_fromyml_keycloak+=($eachline)
										    ;;

										  	couchdb)
										    		#echo -n "couchdb"
										    		var_array_fromyml_couchdb+=($eachline)

										    ;;

										    dicomweb)
										    		#echo -n "dicomweb"
										    		var_array_fromyml_dicomweb+=($eachline)

										    ;;

										    epadlite)
										    		#echo -n "epadlite"
										    		var_array_fromyml_epadlite+=($eachline)

										    ;;

										    epadjs)
										    		#echo -n "epadjs"
										    		var_array_fromyml_epadjs+=($eachline)

										    ;;

										    mariadb)
										    		#echo -n "mariadb"
										    		var_array_fromyml_mariadb+=($eachline)
										    ;;
											esac

								  fi


								done < "$input"

								  	#echo "*******************"
								    #echo "*******************"

								     # echo "${var_array_fromyml_keycloak[@]}"
								      #echo "*******************"
								      #echo "*******************"
								      #echo "${var_array_fromyml_couchdb[@]}"
								      #    echo "*******************"
								      #echo "*******************"
								      #echo "${var_array_fromyml_dicomweb[@]}"
								      #         echo "*******************"
								      #echo "*******************"
								      #echo "${var_array_fromyml_epadlite[@]}"
								      #    echo "*******************"
								      #echo "*******************"
								      #echo "${var_array_fromyml_epadjs[@]}"
								      #    echo "*******************"
								      #echo "*******************"
								      #echo "${var_array_fromyml_mariadb[@]}" 
						fi
				else
					echo "error: couldn't find epad.yml file in $var_path/$var_epadDistLocation"
					exit 1
				fi
			fi

		}
		find_val_fromsections(){
			local found=""
			case $1 in

						  	keycloak)
						    		#echo  "finding in keycloak"
						    		#echo "${var_array_fromyml_keycloak[@]}"
						    		for i in ${!var_array_fromyml_keycloak[@]}; do
	  									found=$(echo "${var_array_fromyml_keycloak[$i]}" | grep -w $2)
	  									if [ ! -z $found ];then
	  										found=$(echo $found | cut -d":" -f2)
	  										break
	  									fi
									done
									echo $found
						    ;;

						  	couchdb)
						    		#echo "finding in couchdb"
						    		#echo "${var_array_fromyml_couchdb[@]}"
						    		for i in ${!var_array_fromyml_couchdb[@]}; do
	  									found=$(echo "${var_array_fromyml_couchdb[$i]}" | grep -w $2)
	  									if [ ! -z $found ];then
	  										found=$(echo $found | cut -d":" -f2)
	  										break
	  									fi
									done
									echo $found

						    ;;

						    dicomweb)
						    		#echo "finding in dicomweb"
						    		#echo "${var_array_fromyml_dicomweb[@]}"
						    		for i in ${!var_array_fromyml_dicomweb[@]}; do
	  									found=$(echo "${var_array_fromyml_dicomweb[$i]}" | grep -w $2)
	  									if [ ! -z $found ];then
	  										found=$(echo $found | cut -d":" -f2)
	  										break
	  									fi
									done
									echo $found


						    ;;

						    epadlite)
						    		#echo  "finding in epadlite"
						    		#echo "${var_array_fromyml_epadlite[@]}"
						    		for i in ${!var_array_fromyml_epadlite[@]}; do
	  									found=$(echo "${var_array_fromyml_epadlite[$i]}" | grep -w $2)
	  									if [ ! -z $found ];then
	  										found=$(echo $found | cut -d":" -f2)
	  										break
	  									fi
									done
									echo $found

						    ;;

						    epadjs)
						    		#echo "finding in epadjs"
						    		#echo "${var_array_fromyml_epadjs[@]}"
						    		for i in ${!var_array_fromyml_epadjs[@]}; do
	  									found=$(echo "${var_array_fromyml_epadjs[$i]}" | grep -w $2)
	  									if [ ! -z $found ];then
	  										found=$(echo $found | cut -d":" -f2)
	  										echo $found
											break
	  									fi
									done
									echo $found

						    ;;

						    mariadb)
						    		#echo "finding in mariadb"
						    		#echo "${var_array_fromyml_mariadb[@]}"
						    		for i in ${!var_array_fromyml_mariadb[@]}; do
	  									found=$(echo "${var_array_fromyml_mariadb[$i]}" | grep -w $2)
	  									if [ ! -z $found ];then
	  										found=$(echo $found | cut -d":" -f2)
	  										break
	  									fi
									done
									echo $found
						    ;;
							esac

		}

		rollback_epadyml_formariadb_credentials(){
				local var_check_failed=""
				local var_check_success=""
				echo "parameter passed : $1"
				# needs to check if user credentials failed for mariadb?
				#check the array if contains fails. 
				#${dokcerprocessrsult_formariacredentials[@]}
				echo "ROOLBACK phase -: verifying which credential need to be rolled back :  ${dokcerprocessrsult_formariacredentials[@]}"
				var_check_failed=$(echo "${dokcerprocessrsult_formariacredentials[@]}" | grep "FAILED")
				var_check_success=$(echo "${dokcerprocessrsult_formariacredentials[@]}" | grep "SUCCESS")
				echo "rollback necessary for the following situations : $var_check_failed"
				if [[ ! -z $var_check_failed ]]; then
					for i in ${!arrayImages[@]}; do
  						
  						if [[ ${arrayImages[$i]} == "updaterootpassLocalhostFAILED" ]] || [[ ${arrayImages[$i]} == "updaterootpassFAILED" ]]; then
  							# edit epad.yml
  							sed -i -e "s/rootpassword:.*/rootpassword: $var_maria_rootpass_old/g" "$var_path/$var_epadDistLocation/epad.yml"
  							echo -e "${Yellow}process: Rolled back mariadb root pass from ->$var_maria_rootpass to -> $var_maria_rootpass_old for epad.yml"
							echo -e "${Color_Off}"
							# edit the compose file also
							sed -i -e "s/ARG_EPAD_DOCKER_GID:.*/ARG_EPAD_DOCKER_GID: $var_local_docker_gid/g" "$var_path/$var_epadLiteDistLocation/docker-compose.yml"
  						fi
  						
  						if [[ ${arrayImages[$i]} == "updateuserFAILED" ]]; then
  							awk -v var_awk="user: $var_maria_user_old" '/user:.*/{c++; if (c==3) { sub("user:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
  							echo -e "${Yellow}process: Rolled back mariadb user from ->$var_maria_user to -> $var_maria_user_old for epad.yml"
  							echo -e "${Color_Off}"
  						fi

  						if [[ ${arrayImages[$i]} == "updateuserpassFAILED" ]]; then
  							awk -v var_awk="password: $var_maria_user_pass_old" '/password:.*/{c++; if (c==3) { sub("password:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
  							echo -e "${Yellow}process: Rolled back mariadb user password from ->$var_maria_pass to -> $var_maria_user_pass_old for epad.yml"
  							echo -e "${Color_Off}"
  						fi
					done
					#	updaterootpassLocalhostFAILED updaterootpassFAILED updateuserFAILED updateuserpassFAILED
			 		
					
					echo -e "${Yellow}process: Rolling back epad.yml finished. Recreating epad_lite_dist"
					echo -e "${Color_Off}"
					create_epad_lite_dist
					if [ -d "$var_path/$var_epadLiteDistLocation" ]; then
						cd "$var_path/$var_epadLiteDistLocation"
						echo -e "${Yellow}process: Restarting ePad containers to reflect the old credentials to the containers"
						echo -e "${Color_Off}"
						docker-compose up -d > "$var_path/epad_manage.log"
					else
						echo -e "${Yellow}process: Could not locate epad_lite_dist folder at location : $var_path/$var_epadLiteDistLocation to restart containers with rolled back mariadb credentials"
						echo -e "${Color_Off}"
					fi
					
                	
					# docker restart epad_lite
					
				else
					echo -e "${Yellow}process: check failed status: empty. Nothing to rollback"
					echo -e "${Color_Off}"
				fi

				if [[ ! -z $var_check_success ]]; then
					echo -e "${Yellow}process: restarting epad_mariadb"
					echo -e "${Color_Off}"
					docker restart epad_mariadb
				fi

				

		}

		update_mariadb_usersandpass(){
			# new : need testing
			local edited=0
			local maria_container_exist=""
			
			local result=""
			local verifyfirst=""
			local var_sql_socket_ready=""
			
			#var_maria_rootpass_old="admin"
			#var_maria_rootpass="cavit"

			echo -e "${Yellow}process: updating  mariadb users and passwords"
			echo -e "${Color_Off}"
			#echo "old root pass:$var_maria_rootpass_old"
			#echo "new root pass:$var_maria_rootpass"
			#echo "old user:$var_maria_user_old"
			#echo "new user:$var_maria_user"
			#echo "old user pass : $var_maria_user_pass_old"
			#echo "new user pass : $var_maria_pass"
			
			#if [[ $var_reinstalling == "true" ]]; then
				maria_container_exist=$(docker ps -a --filter "name=\bepad_mariadb\b" --format "table {{.Status}}" | grep Up)
				if [[ ! -z $maria_container_exist ]]; then
					if [[ ! -z $var_maria_rootpass ]] && [[ ! -z $var_maria_rootpass_old ]] && [[ ! -z $var_maria_pass ]] && [[ ! -z $var_maria_user_pass_old ]] && [[ ! -z $var_maria_user ]] && [[ ! -z $var_maria_user_old ]]; then
									# docker exec --user root  -it epad_mariadb  apt-get update
									if [[ $var_maria_rootpass_old != $var_maria_rootpass ]]; then

										echo -e "${Yellow}process: editing root password in epad_mariadb container"
										echo -e "${Color_Off}"
										
										# we need to wait for the sockek to be ready

										var_sql_socket_ready="socket"
										while [[ ! -z "$var_sql_socket_ready" ]]; do
											
										    echo "waiting for sql socket"
										    
										   
										    var_sql_socket_ready=$(docker exec -it  epad_mariadb  mysql -uroot -p$var_maria_rootpass -e  "use mysql;show databases;")
										    var_sql_socket_ready=$(echo "$var_sql_socket_ready" | grep "socket")
										    echo "1 var_sql_socket_ready : $var_sql_socket_ready"
										    

										    if [[ -z "$var_sql_socket_ready" ]]; then
										    	var_sql_socket_ready=$(docker exec -i epad_mariadb  mysql -uroot -p$var_maria_rootpass_old -e "use mysql;show databases;" )
										    	var_sql_socket_ready=$(echo "$var_sql_socket_ready" | grep "socket")
										    	echo "2 in var_sql_socket_ready : $var_sql_socket_ready"
										    	#var_sql_socket_ready="socket"
										    fi
										    
										     sleep 5
										done
										
										
										echo -e "${Yellow}process: mariadb socket ready for the root credentials update..."
										echo -e "${Color_Off}"

										verifyfirst="$(docker exec  -it  epad_mariadb  mysql -uroot -p$var_maria_rootpass -e "use mysql;show databases;" || echo "failed")"
										echo "root user verifyfirst :$verifyfirst"
										if [[ "$verifyfirst"=="failed" ]]; then
											echo "new root pass failed so need to update"
											result=$(docker exec  -i  epad_mariadb  mysql -uroot -p$var_maria_rootpass_old <<< "use mysql; ALTER USER 'root'@'localhost' IDENTIFIED BY '"$var_maria_rootpass"';FLUSH PRIVILEGES;"  && echo "updaterootpasslocalhostSUCCESS" || echo "updaterootpassLocalhostFAILED") # > result
											dokcerprocessrsult_formariacredentials+=($result)
											echo "a1 : $result"
											
											#result=$(docker exec  -i  epad_mariadb  mysql -uroot -p$var_maria_rootpass <<< "use mysql; ALTER USER 'root'@'%' IDENTIFIED BY '"$var_maria_rootpass"';FLUSH PRIVILEGES;" && echo "updaterootpassSUCCESS" || echo "updaterootpassFAILED") # > result
											result=$(docker exec  -i  epad_mariadb  mysql -uroot -p$var_maria_rootpass <<< "use mysql; ALTER USER 'root'@'%' IDENTIFIED BY '"$var_maria_rootpass"';FLUSH PRIVILEGES;" && echo "updaterootpassSUCCESS" || echo "updaterootpassFAILED") # > result
											dokcerprocessrsult_formariacredentials+=($result)
											echo "a2 : $result"
											edited=1

										fi
									else
										echo "no need to update root password in mariadb"
									fi




									if [[ $var_maria_user != $var_maria_user_old ]]  || [[ $var_maria_pass != $var_maria_user_pass_old ]]; then
										echo -e "${Yellow}process: editing mariadb user and password in epad_mariadb container"
										echo -e "${Color_Off}"

										# we need to wait for the sockek to be ready

										var_sql_socket_ready="socket"
										while [[ ! -z $var_sql_socket_ready ]]; do
											
										    echo "waiting for sql socket"
										    
										   
										    var_sql_socket_ready=$(docker exec -it  epad_mariadb  -u$var_maria_user -p$var_maria_pass  -e   "use epaddb;show tables;" )
										    var_sql_socket_ready=$(echo "$var_sql_socket_ready" | grep "socket")
										    echo "3 var_sql_socket_ready : $var_sql_socket_ready"
										    

										    if [[ -z $var_sql_socket_ready ]]; then
										    	var_sql_socket_ready=$(docker exec -i epad_mariadb  mysql -u$var_maria_user_old -p$var_maria_user_pass_old  -e   "use epaddb;show tables;"  )
										    	var_sql_socket_ready=$(echo "$var_sql_socket_ready" | grep "socket")
										    	 echo "4 var_sql_socket_ready : $var_sql_socket_ready"
										    	 #var_sql_socket_ready="socket"
										    fi
										    
										     sleep 5
										done

										# var_sql_socket_ready="socket"
										# while [[ -z $var_sql_socket_ready ]]; do
											
										#     echo "waiting for sql socket"
										    
										   
										#     var_sql_socket_ready=$(docker exec  -it epad_mariadb  mysqladmin -u$var_maria_user -p$var_maria_pass  -e  "use mysql;show databases;" )
										#     echo "var_sql_socket_ready : $var_sql_socket_ready"

										#     if [[ -z $var_sql_socket_ready ]]; then
										#     	var_sql_socket_ready=$(docker exec  -it epad_mariadb  mysqladmin -u$var_maria_user_old -p$var_maria_user_pass_old  -e  "use mysql;show databases;" )
										#     fi
										    
										#      sleep 5
										# done
										echo -e "${Yellow}process: mariadb socket ready for the user credentials update..."
										echo -e "${Color_Off}"

										verifyfirst="$(docker exec  -it  epad_mariadb  mysql -u$var_maria_user -p$var_maria_pass -e "use epaddb;show tables;" || echo "failed")"
										echo "regular user verifyfirst :$verifyfirst"
										if [[ "$verifyfirst"=="failed" ]]; then
											#dokcerprocessrsult_formariacredentials+=($())
											result=$(docker exec  -i  epad_mariadb  mysql -uroot -p$var_maria_rootpass <<< "use mysql; update user set User = '"$var_maria_user"' where User='"$var_maria_user_old"' ;FLUSH PRIVILEGES;" && echo "updateuserSUCCESS" || echo "updateuserFAILED")
											dokcerprocessrsult_formariacredentials+=($result)
											echo "a3 : $result"
											if [[ "$result"=="updateuserSUCCESS" ]]; then
												result=$(docker exec  -i  epad_mariadb  mysql -uroot -p$var_maria_rootpass <<< "use mysql; GRANT ALL ON epaddb.* TO '"$var_maria_user"'@'%'; ;FLUSH PRIVILEGES;" && echo "updateusertableprivillegeSUCCESS" || echo "updateusertableprivillegeFAILED")
												dokcerprocessrsult_formariacredentials+=($result)
												echo "aX : $result"
											fi
											
											#GRANT ALL ON epaddb.* TO 'cavit'@'%';
											result=$(docker exec  -i  epad_mariadb  mysql -uroot -p$var_maria_rootpass <<< "use mysql; ALTER USER '"$var_maria_user"'@'%' IDENTIFIED BY '"$var_maria_pass"';FLUSH PRIVILEGES;" && echo "updateuserpassSUCCESS" || echo "updateuserpassFAILED")
											dokcerprocessrsult_formariacredentials+=($result)
											echo "a4 : $result"
											edited=2
										
										fi
									else
										echo "no need to update user name or password in mariadb"
									fi

									if [[ $edited > 0 ]]; then
										echo -e "${Yellow}process: restarting epad_mariadb container "
										echo -e "${Color_Off}"
										rollback_epadyml_formariadb_credentials
										
										# if credentials update fails need to rollback epad.yml for mariadb user credentials .Same for docker-compose.yml
									fi
					else
						echo "user or password is empty for user or root. Mariadb credentials left as is."
						rollback_epadyml_formariadb_credentials
					fi
				else
					echo "could not locate epad_mariadb container"
					echo "rolling back epad.yml with old mariadb credentials"
					rollback_epadyml_formariadb_credentials "no_container_rollback"
					
				fi
			#fi
			#echo "mariadb credential update check :  ${dokcerprocessrsult_formariacredentials[@]}"
			failvalue=$(echo "${dokcerprocessrsult_formariacredentials[@]}" | grep "FAILED")
			#echo "failed ? : $failvalue"
			succesvalue=$(echo "${dokcerprocessrsult_formariacredentials[@]}" | grep "SUCCESS")
			#echo "success ? : $succesvalue"
		}

		delete_epad_data(){
		# new : need testing
			# this section will delete couchdb and maria db folders
			echo -e "${Yellow}process: deleting epad data"
			echo -e "${Color_Off}"

			local var_resp_delete="n"
			read -p " Your couchdb and mariadb data will be erased. Do you want to proceed (y/n) default answer is (n) : " var_resp_delete
			# if [[ -z $var_resp_delete ]]; then
			# 	echo "empty"
			# 	echo "var_resp_delete:$var_resp_delete"
			# else
			# 	echo "not empty"
			# 	echo "var_resp_delete:$var_resp_delete"
			# fi

		}


		delete_dangling_images(){
			echo -e "${Yellow}process: deleting dangling images"
			echo -e "${Color_Off}"
			docker rmi -f $(docker images -f "dangling=true" -q)
		}

		remove_epad_images(){
			local arrayImages=()
			echo -e "${Yellow}process: deleting ePad images"
			echo -e "${Color_Off}"
			arrayImages+=($(docker ps -a --filter "name=\bepad_js\b" --format "table {{.Image}}" | awk '{ getline; print $0;}'))
			arrayImages+=($(docker ps -a --filter "name=\bepad_lite\b" --format "table {{.Image}}" | awk '{ getline; print $0;}'))
			arrayImages+=($(docker ps -a --filter "name=\bepad_dicomweb\b" --format "table {{.Image}}" | awk '{ getline; print $0;}'))
			arrayImages+=($(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Image}}" | awk '{ getline; print $0;}'))
			arrayImages+=($(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Image}}" | awk '{ getline; print $0;}'))
			arrayImages+=($(docker ps -a --filter "name=\bepad_mariadb\b" --format "table {{.Image}}" | awk '{ getline; print $0;}'))
			stop_containers_all
			remove_containers_all
			echo "removing epad images : ${arrayImages[@]}"
			for i in ${!arrayImages[@]}; do
  				docker rmi  ${arrayImages[$i]} > "$var_path/epad_manage.log"
			done
			# docker rmi $("${arrayImages[@]}") 
			#docker rmi $(docker ps -a --filter "name=\bepad_js\b" --format "table {{.Image}}" | awk '{ getline; print $0;}')
			#docker rmi $(docker ps -a --filter "name=\bepad_lite\b" --format "table {{.Image}}" | awk '{ getline; print $0;}')
			#docker rmi $(docker ps -a --filter "name=\bepad_dicomweb\b" --format "table {{.Image}}" | awk '{ getline; print $0;}')
			#docker rmi $(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Image}}" | awk '{ getline; print $0;}')
			#docker rmi $(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Image}}" | awk '{ getline; print $0;}')
			#docker rmi $(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Image}}" | awk '{ getline; print $0;}')
		}

		check_ifallcontainers_created(){
			local var_counter=0
			local var_result=""
			var_result=$(docker ps -a | grep "\bepad_js\b")
			if [[ ! -z $var_result ]]; then
				var_counter=$(($var_counter + 1))
			fi
			var_result=$(docker ps -a | grep "\bepad_lite\b")
			if [[ ! -z $var_result ]]; then
				var_counter=$(($var_counter + 1))
			fi
			var_result=$(docker ps -a | grep "\bepad_dicomweb\b")
			if [[ ! -z $var_result ]]; then
				var_counter=$(($var_counter + 1))
			fi
			var_result=$(docker ps -a | grep "\bepad_keycloak\b")
			if [[ ! -z $var_result ]]; then
				var_counter=$(($var_counter + 1))
			fi
			var_result=$(docker ps -a | grep "\bepad_couchdb\b")
			if [[ ! -z $var_result ]]; then
				var_counter=$(($var_counter + 1))
			fi

			var_result=$(docker ps -a | grep "\bepad_mariadb\b")
			if [[ ! -z $var_result ]]; then
				var_counter=$(($var_counter + 1))
			fi

			if [[ $var_counter < 6 ]]; then
				global_var_container_exist="doesnt"
			else
				global_var_container_exist="exist"
			fi
		}

		check_existance_couchdb_usercred(){
			local var_couchdb_lineno=0
			local var_string=""
			

			var_couchdb_lineno=$(grep -n 'couchdb:' "$var_path/$var_epadDistLocation/epad.yml"  | cut -d":" -f1 )
			var_couchdb_lineno=$(($var_couchdb_lineno + 3))

			var_string=$(cat "$var_path/$var_epadDistLocation/epad.yml" | grep "couchuser")
			if [[ -z $var_string ]]; then
				awk 'NR=='$var_couchdb_lineno'{print "  couchuser: \"'$var_couchuser'\" " }1' "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml" "$var_path/$var_epadDistLocation/epad.yml"
				var_couchdb_lineno=$(grep -n 'couchuser' "$var_path/$var_epadDistLocation/epad.yml"  | cut -d":" -f1 )
			else
				var_couchdb_lineno=$(grep -n 'couchuser' "$var_path/$var_epadDistLocation/epad.yml"  | cut -d":" -f1 )
			fi

			var_string=$(cat "$var_path/$var_epadDistLocation/epad.yml" | grep "couchpassword")
			if [[ -z $var_string ]]; then
				var_couchdb_lineno=$(($var_couchdb_lineno + 1))
				awk 'NR=='$var_couchdb_lineno'{print "  couchpassword: \"'$var_couchpassword'\" " }1' "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml" "$var_path/$var_epadDistLocation/epad.yml"
			fi
			
			
		}

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
				var_container_situation=$(docker ps -a --filter "name=\bepad_lite\b" --format "table {{.Status}}" | grep 'Exited\|unhealthy' )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi


			var_container_situation=$(docker ps -a --filter "name=\bepad_js\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_js"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_js\b" --format "table {{.Status}}" | grep 'Exited\|unhealthy')
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_dicomweb\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_dicomweb"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_dicomweb\b" --format "table {{.Status}}" | grep 'Exited\|unhealthy' )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_keycloak"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}" | grep 'Exited\|unhealthy' )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_couchdb"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_couchdb\b" --format "table {{.Status}}" | grep 'Exited\|unhealthy' )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			var_container_situation=$(docker ps -a --filter "name=\bepad_mariadb\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" == "STATUS" ]]; then
				var_total_fail=$(( $var_total_fail + 1))
				var_failed_container_names="$var_failed_container_names epad_mariadb"
			else
				var_container_situation=$(docker ps -a --filter "name=\bepad_mariadb\b" --format "table {{.Status}}" | grep 'Exited\|unhealthy' )
				if [[ ! -z $var_container_situation ]]; then
					var_total_fail=$(( $var_total_fail + 1))
				fi
			fi

			# docker ps -a -f status=exited | grep "\bepad_lite\b"
			# echo $var_total_fail

			if [[ $var_total_fail > 0 ]]; then
				echo "there are failed containers"
				# docker ps -a -f 'health=unhealthy'
				# health=unhealthy
				var_counter=$(docker ps -a -f 'status=exited' |  wc -l | awk ' {print $1}')
				# echo "var_counter $var_counter"
				if [[ $var_counter == 0 ]]; then
					var_counter=$(docker ps -a -f 'health=unhealthy' |  wc -l | awk ' {print $1}')
				fi
				if [[ $var_counter > 0 ]]; then
					docker ps -a -f 'status=exited'
					docker ps -a -f 'health=unhealthy'
				fi
				# echo "Please contact epad team!"
				if [[ "$var_failed_container_names" != "" ]]; then
					echo "ePad couldn't find following containers : $var_failed_container_names . Please install ePad or contact ePad team"
				fi
				exit 1
			fi

		}

		check_keycloak_container_situation(){
			local var_container_situation=""
			var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}"  )
			if [[ "$var_container_situation" != "STATUS" ]]; then
				# echo "container epad_keycloak does not exist. Please start epad first "
				#exit 1

				var_container_situation=$(docker ps -a --filter "name=\bepad_keycloak\b" --format "table {{.Status}}" | grep Up )
				if [[  -z $var_container_situation ]]; then
					echo "container epad_keycloak is not running. Please start epad first "
					exit 1
				fi
			else
				echo "noop"
			fi
		}

		find_os_type(){
		echo -e "${Yellow}process: finding os type"
		echo -e "${Color_Off}"
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
		if [[ -f "$var_path/$var_epadDistLocation/epad.yml" ]]; then
			var_tmp_txt=$( awk "/$1/{i++}i==$2{print; exit}"  "$var_path/$var_epadDistLocation/epad.yml")
 			var_tmp_txt=$( echo $var_tmp_txt | cut -d: -f2)
                #hostname loaded from epad.yml to variable
			echo $var_tmp_txt
		else
			echo ""
		fi
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
		
		
		find_os_type
		local var_hostname_from_epadyml=""
		local var_ip_frometc=""
		local var_fresh_ip=""
		local iffixed_hostname_etchosts="epadvm"
		var_hostname_from_epadyml=$(find_val_intext "host:" "1")
		echo "host name from epad.yml :  $var_hostname_from_epadyml"
		if [[ "$iffixed_hostname_etchosts" == "$var_hostname_from_epadyml" ]]; then
			echo "checking ip mapping..."
			var_ip_frometc=$( cat /etc/hosts | grep "\b$var_hostname_from_epadyml\b" | awk '{print $1}' )
			# echo $var_ip_frometc
			if [[ ! -z $var_ip_frometc ]]; then
				echo "there is an ip found : $var_ip_frometc "
				var_fresh_ip=$(find_ip)
				echo "mapped ip needs to be : $var_fresh_ip"
				if [[ $var_ip_frometc != $var_fresh_ip ]]; then
					echo "you need to refresh the ip in /etc/hosts file. Please run the script epad_fixmyip.sh which is located in epad-dist folder. This operation requires sudo right"
					exit 1
				else
					echo "your ip : $var_ip_frometc is a valid ip."
				fi
			fi
		fi

	}

	find_hostname_from_hostsfile(){
	echo -e "${Yellow}process: finding machine name from etc/hosts"
	echo -e "${Color_Off}"
		# local var_local_servername=""
		# var_res=$(find_ip)
		local var_server_name="epadvm" # this is the server name required to be in the /etc/hosts file
		local var_ip=$(find_ip)
		local var_return=""
		echo "your actual ip : $var_ip"
		#var_local_servername=$( cat /etc/hosts | grep $var_res )
		var_return=$( cat /etc/hosts | grep $var_server_name )
		if [[ -z "$var_return" ]]; then
            echo "could not find your hostname : $var_server_name in your /etc/hosts file please fix your ip manually or use epad_fixmyip.sh script which is located in your epad-dist folder"
            exit 1
        else
            echo -e "your hostname : $var_server_name found in /etc/hosts file.\nverifying if it has a vlid ip"
			var_return=$( cat /etc/hosts | grep $var_server_name | awk '{print $1}' )
			
			if [[ -z "$var_return" ]]; then
				echo "no valid ip found for $var_server_name please fix your ip manually or use epad_fixmyip.sh script which is located in your epad-dist folder"
				echo "exiting ..."
				exit 1
				#var_host=$var_res
				#echo "your host name for epad is set to $var_host"
				
			else
				echo -e "ip collected from /etc/hosts for $var_server_name is : $var_return and needs to match with : $var_ip\n"
				if [[ "$var_return" == "$var_ip" ]]; then
					var_host=$var_server_name
				else
					echo -e "${Purple}"
					echo "You have an old ip mapped to $var_server_name. Please update your ip manually in /etc/hhosts file or use epad_fixmyip.sh script which is located in your epad-dist folder to updated your ip automatically."
					echo "exiting ..."
					echo -e "${Color_Off}"
					exit 1
				fi
			fi
        fi
	}
	
	edit_hosts_file(){
	echo -e "${Yellow}process: editing /etc/hosts"
 	echo -e "${Color_Off}"
 	local totalfiles=0
 	totalfiles=$(ls /etc/hosts* | wc -l | awk ' {print $1}')
 	totalfiles=$(($totalfiles + 1))
 	cp /etc/hosts /etc/hosts_epad_backup_$totalfiles
		var_res=$(cat /etc/hosts | grep $var_ip)
        if [[ -z "$var_res" ]]; then
            echo "ip not found"
			echo "$var_ip $var_host" >> /etc/hosts
        else
            echo "$var_res is already in etc"
			var_res_epadvm=$( echo $var_res | grep epadvm )
			echo "checking if epadvm is in /etc/hosts "
			echo $var_res_epadvm
			if [[ -z "$var_res_epadvm" ]]; then
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
		# if [[ -z $var_install_result_r  ||   "$var_install_result_r" != "y" ]]; then
		
			#if [[ $var_host == "" || $var_host == "YOUR_HOSTNAME" ]];then
				if [[ $HOSTNAME == "" ]]; then
					echo "hostname : $HOSTNAME is empty checking etc/hosts file to find server name"
					find_hostname_from_hostsfile
				else
					echo -e "${Purple}"
					echo "If you used epad_fixmyip.sh script to fix your server name answer 2 for the following question!"
					echo -e "${Color_Off}"
					#read -p "You have a valid hostname env variable $HOSTNAME.Do you want to use this (1) or do you want to grap hostname by using /etc/hosts (2) ? ( 1 or 2 ) : " var_resp
					askInputLoop "You have a valid hostname env variable $HOSTNAME.Do you want to use this (1) or do you want to get the hostname from /etc/hosts (2) or do you want to use previous value/manual setup (3)  ? ( 1 , 2 or 3 ) : " var_resp "" "1-3"
	                if [[ $var_resp == 1 ]]; then
						#var_host=$HOSTNAME
						var_host=$(echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]')
					elif [[ $var_resp == 3 ]]; then
					    var_host=$( find_val_intext "host:" "1")
					else
						find_hostname_from_hostsfile
					fi
				fi
			#fi
		#fi
	}

	load_credentials_tovar (){
		local localvar_getresult=""
		echo -e "${Yellow}process: loading credentials from epad.yml to variables for a new epad.yml"
		echo -e "${Color_Off}"
		#echo $var_path
		parse_yml_sections
		#var_tmp_txt=""
		#var_tmp_txt=$( awk '/host/{i++}i==1{print; exit}'  "$var_path/$var_epadDistLocation/epad.yml")
		#var_host=$( echo $var_tmp_txt | cut -d: -f2)
		var_host=$( find_val_intext "host:" "1")
		#echo "var_host: $var_host"
		var_mode=$( find_val_intext "mode:" "1")
        var_config=$( find_val_intext "config:" "1")
        #var_container_mode==$( find_val_intext "host" "1")
        var_couchdb_location=$( find_val_intext "dblocation:" "1")
		var_couchdb_location=$(echo $var_couchdb_location | sed 's/"//g')
        var_mariadb_location=$( find_val_intext "dblocation:" "2")
        var_mariadb_location=$(echo $var_mariadb_location | sed 's/"//g')
        
	        #var_keycloak_user=$( find_val_intext "user:" "1")
	        #var_keycloak_pass=$( find_val_intext "password:" "1")
	        #var_keycloak_useremail=$( find_val_intext "email:" "1")
	        var_keycloak_user=$( find_val_fromsections "keycloak" "user")
        	var_keycloak_pass=$( find_val_fromsections "keycloak" "pass")
        	if [[  $var_keycloak_pass == "" ]];then
        		var_keycloak_pass=$( find_val_fromsections "keycloak" "password")
        	fi
        	var_keycloak_useremail=$( find_val_fromsections "keycloak" "email")

        	#var_couchdb_user=$( find_val_intext "user:" "2")
       		#var_couchdb_pass=$( find_val_intext "password:" "2")
       		var_couchdb_user=$( find_val_fromsections "couchdb" "user")
        	var_couchdb_pass=$( find_val_fromsections "couchdb" "password")

		        #var_maria_user=$( find_val_intext "user:" "3")
		        #var_maria_pass=$( find_val_intext "password:" "3")
		        #var_maria_rootpass=$( find_val_intext "rootpassword:" "1")
		        var_maria_user=$(find_val_fromsections "mariadb" "user")
		        var_maria_pass=$(find_val_fromsections "mariadb" "pass")
		        if [[  $var_maria_pass == "" ]];then
		        	var_maria_pass=$(find_val_fromsections "mariadb" "password")
		        fi
		        var_maria_rootpass=$(find_val_fromsections "mariadb" "rootpass")
		         if [[  $var_maria_rootpass == "" ]];then
		         	var_maria_rootpass=$(find_val_fromsections "mariadb" "rootpassword")
		         fi
        
        var_maria_rootpass_old=$var_maria_rootpass
		var_maria_user_old=$var_maria_user
		var_maria_user_pass_old=$var_maria_pass
		
		localvar_getresult=$( find_val_intext "branch:" "1")
		if [[ -n $localvar_getresult ]]; then
        	var_branch_dicomweb=$localvar_getresult
        	var_branch_dicomweb=$(echo $var_branch_dicomweb | sed 's/"//g')
        	localvar_getresult=""
        fi

        localvar_getresult=$( find_val_intext "branch:" "2")
        if [[ -n $localvar_getresult ]]; then
        	var_branch_epadlite=$localvar_getresult
        	var_branch_epadlite=$(echo $var_branch_epadlite | sed 's/"//g')
        	localvar_getresult=""
        fi

        localvar_getresult=$( find_val_intext "branch:" "3")
        if [[ -n $localvar_getresult ]]; then
        	var_branch_epadjs=$localvar_getresult
        	var_branch_epadjs=$(echo $var_branch_epadjs | sed 's/"//g')
        	localvar_getresult=""
        fi

        #load ports from old yml
        localvar_getresult=$(find_val_fromsections "keycloak" "port")
        if [[ -n $localvar_getresult ]]; then
        	var_keycloak_port=$localvar_getresult
        	var_keycloak_port=$(echo $var_keycloak_port | sed 's/"//g')
        	localvar_getresult=""
    	fi 

    	localvar_getresult=$(find_val_fromsections "epadjs" "port")
    	if [[ -n $localvar_getresult ]]; then
        	var_epadjs_port=$localvar_getresult
        	var_epadjs_port=$(echo $var_epadjs_port | sed 's/"//g')
        	localvar_getresult=""
        fi

        localvar_getresult=$(find_val_fromsections "epadlite" "port")
        if [[ -n $localvar_getresult ]]; then
        	var_epadlite_port=$localvar_getresult
        	var_epadlite_port=$(echo $var_epadlite_port | sed 's/"//g')
        	localvar_getresult=""
        fi

        localvar_getresult=$(find_val_fromsections "dicomweb" "port")
        if [[ -n $localvar_getresult ]]; then
        	var_dicomweb_port=$localvar_getresult
        	var_dicomweb_port=$(echo $var_dicomweb_port | sed 's/"//g')
        	localvar_getresult=""
        fi

        localvar_getresult=$(find_val_fromsections "couchdb" "port")
        if [[ -n $localvar_getresult ]]; then
        	var_couchdb_port=$localvar_getresult
        	var_couchdb_port=$(echo $var_couchdb_port | sed 's/"//g')
        	localvar_getresult=""
        fi

        localvar_getresult=$(find_val_fromsections "mariadb" "port")
        if [[ -n $localvar_getresult ]]; then
        	var_maria_port=$localvar_getresult
        	var_maria_port=$(echo $var_maria_port | sed 's/"//g')
        	localvar_getresult=""
        fi
		# echo "loaded variables from epad.yml : ++++++++++++++++ "
		# echo " var_host :$var_host"
	 #    echo " var_mode :$var_mode"
	 #    echo " var_config :$var_config"
	 #    echo " var_container_mode:$var_container_mode"
	   
	   
	    #echo " var_branch:$var_branch"
	    
	            
	    # echo " var_keycloak_user:$var_keycloak_user"
	    # echo " var_keycloak_pass:$var_keycloak_pass"
	    # echo " var_keycloak_useremail:$var_keycloak_useremail"

	    # echo " var_maria_user:$var_maria_user"
	    # echo " var_maria_pass:$var_maria_pass"
	    # echo " var_maria_rootpass:$var_maria_rootpass"
	    #  echo " var_mariadb_location:$var_mariadb_location"

	    # echo " var_couch_user:$var_couchdb_user"
	    # echo " var_couch_pass:$var_couchdb_pass"
	    #  echo " var_couchdb_location:$var_couchdb_location"
	    

	    # echo "  dicomweb branch: $var_branch_dicomweb"
	    # echo "  epadlite branch: $var_branch_epadlite"
	    # echo "  epadjs branch: $var_branch_epadjs"

	    # echo "ports : "
	    # echo "keycloak port : $var_keycloak_port"
	    # echo "epadjs port : $var_epadjs_port"
	    # echo "epadlite port : $var_epadlite_port"
	    # echo "dicomweb port : $var_dicomweb_port"
	    # echo "couch port : $var_couchdb_port"
	    # echo "maria port : $var_maria_port"
	} 
	
	find_docker_gid(){

		echo -e "${Yellow}process: finding docker group id"
		echo -e "${Color_Off}"

		var_local_docker_gid=$( cat /etc/group | grep docker | cut -d: -f3)
		if [[ -z $var_local_docker_gid ]]; then
			echo "docker gid : not found. normal for mac os"
		else
			echo "docker gid : $var_local_docker_gid"
		fi
		
	}

	copy_epad_dist (){

		local needymlupdate=""
		local backupymlfilename=""

		echo -e "${Yellow}process: copying epad-dist from git.."
		echo -e "${Color_Off}"

		var_response="n"	
		
		if [[ -d "$var_path/$var_epadDistLocation" ]]; then
			#var_reinstalling="true"
			parse_yml_sections
			load_credentials_tovar
	 		
			global_var_container_exist="exist"
			if [[ $var_reinstalling != "true" ]]; then
  				#read -p  "epad-dist folder exist already. Do you want to owerwrite ? (y/n) (defult value is n): " var_response
  				askInputLoop  "epad-dist folder exist already. Do you want to owerwrite ? (y/n) (defult value is n): " var_response "" "y|n"

  			fi
		else
			cd $var_path
  			git clone https://github.com/RubinLab/epad-dist.git
		fi
		#echo "var_response :$var_response "
		#echo "var_reinstalling : $var_reinstalling"
		if [[ $var_response == "y" ]] || [[ $var_reinstalling == "true" ]]; then

			
			backupymlfilename=$( date  |  sed -e 's/'" "'/-/g' |  sed -e 's/':'/-/g')
			echo -e "${Yellow}process: backing up old epad.yml to -> epad.yml_$backupymlfilename"
			echo -e "${Color_Off}"
	 		
			cp $var_path/$var_epadDistLocation/epad.yml $var_path/epad.yml_$backupymlfilename
  			echo "copying epad-dist repo from git"
			rm -rf "$var_path/$var_epadDistLocation"
			cd $var_path
  			git clone https://github.com/RubinLab/epad-dist.git
		else
			parse_yml_sections
			#echo "needymlupdate : $needymlupdate"
			needymlupdate=$(check_epadyml_needs_update)
			#echo "needymlupdate : $needymlupdate"
			if [[ "$needymlupdate" == "pull" ]]; then
					echo "We detected an old epad.yml. You need to answer yes to owerwrite epad-dist folder. Please retry the process "
					exit 1
			fi
		fi
	}

	create_epad_lite_dist(){
	echo -e "${Yellow}process: building epad_lite_dist from epad.yml"
	echo -e "${Color_Off}"
		var_response="n"
				if [[ -d "$var_path/$var_epadLiteDistLocation" ]]; then
					if [[ $var_reinstalling != "true" ]]; then
						echo -e "${Purple}"
						echo -e "If you updated ePad configuration (user names, passwords, branch names etc.) previously and \nif you want those changes to be reflected to your system, you will need to answer yes \nfor the following question"
                        echo -e "${Color_Off}"
                        #read -p  "epad_lite_dist folder exist already do you want to owerwrite ? (y/n) (defult value is n): " var_response
                        askInputLoop  "epad_lite_dist folder exist already do you want to owerwrite ? (y/n) (defult value is n): " var_response "" "y|n"
                    fi
                else
						cd "$var_path/$var_epadDistLocation"
                        ./configure_epad.sh ../$var_epadLiteDistLocation ./epad.yml
			
                fi

                if [[ $var_response == "y" ]] || [[ $var_reinstalling == "true" ]]; then
                        
                        echo -e "${Yellow}process: creating $var_epadLiteDistLocation folder"
						echo -e "${Color_Off}"
                        rm -rf "$var_path/$var_epadLiteDistLocation"
						cd "$var_path/$var_epadDistLocation"
                        ./configure_epad.sh ../$var_epadLiteDistLocation ./epad.yml
                fi

	}

	stop_containers_all (){
		echo -e "${Yellow}process: stopping ePad containers..."
		echo -e "${Color_Off}"
		#export_keycloak
		#echo $!
		#result=""

		#while [[ -z $result  ]]; do
		#	result=$(cat exportkeycloak.log | grep "Export finished successfully")
		#done

		#echo $result
		
		#if [[ -d "$var_path/$var_epadLiteDistLocation" ]]; then
		#	cd "$var_path/$var_epadLiteDistLocation"
		#	docker-compose stop
		#else

			for i in ${!var_array_allEpadContainerNames[@]}; do
	  				docker stop  ${var_array_allEpadContainerNames[$i]}
			done
		#fi
		
	}

	remove_containers_all (){
		echo -e "${Yellow}process: removing ePad containers..."
		echo -e "${Color_Off}"
		#export_keycloak
		#echo $!
		#result=""

		#while [[ -z $result  ]]; do
		#	result=$(cat exportkeycloak.log | grep "Export finished successfully")
		#done

		#echo $result
		
		#if [[ -d "$var_path/$var_epadLiteDistLocation" ]]; then
		#	cd "$var_path/$var_epadLiteDistLocation"
		#	docker-compose rm -f
		#else

			for i in ${!var_array_allEpadContainerNames[@]}; do
	  				docker rm  ${var_array_allEpadContainerNames[$i]}
			done
		#fi
		
	}

	start_containers_all (){
		echo -e "${Yellow}process: starting ePad containers..."
		echo -e "${Color_Off}"

	
		#echo $var_start
		#echo $var_end
		cd "$var_path/$var_epadLiteDistLocation"
        docker-compose start
        local var_start=$(date +%s)
		local var_end=$(($var_start + 300))
		local linecount=0
		local counter=0
		local var_waiting="starting epad"
		while [[ $linecount -lt 4 && $var_start -lt $var_end ]]; do
			var_start=$(date +%s)
				counter=$((counter+1))
	            linecount=$(docker ps -a  | grep '\bhealthy\b' | wc -l | awk ' {print $1}')
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
        linecount=$(docker ps -a  | grep '\bhealthy\b' | wc -l | awk ' {print $1}')
        if [[ $linecount -lt 4 ]]; then
        	echo "one or more container have issues. ePad couldn't start"
        else
        	echo "epad is ready to browse: http://$var_host"
        fi
	
	}
	build_images_via_nocache (){
		echo -e "${Yellow}process: building ePad containers using docker-compose build --no-cache"
		echo -e "${Color_Off}"
           	cd "$var_path/$var_epadLiteDistLocation"
            docker-compose build --no-cache > "$var_path/epad_manage.log"
	}

	start_containers_viaCompose_all (){
		echo -e "${Yellow}process: starting ePad containers using docker-compose up -d"
		echo -e "${Color_Off}"
           		cd "$var_path/$var_epadLiteDistLocation"
                docker-compose up -d > "$var_path/epad_manage.log"
    #             local var_start_st=$(date +%s)
				# local var_end_st=$(($var_start_st + 300))
				# #echo "init : $var_start_st "
				# #echo "init : $var_end_st "	
    #             local linecount_st=0
    #             local counter_st=0
    #             local var_waiting_st="starting epad"
    #             while [[ $linecount_st -lt 4 ]] && [[ $var_start_st -lt $var_end_st ]]; do
    #             	#echo "loop started "
    #             	var_start_st=$(date +%s)
    #             	#echo "starting time :  $var_start_st " 
    #             	#echo "end time :  $var_end_st " 
    #                     counter_st=$(($counter_st + 1))
    #                     #echo "cntr $counter_st"
    #                     linecount_st=$(docker ps -a  | grep '\bhealthy\b' | wc -l | awk ' {print $1}')

    #                     #echo "line count : $linecount_st "
    #                     if [[ $counter_st > 0 ]]; then
    #                             var_waiting_st="$var_waiting_st."
    #                             echo -en "$var_waiting_st\r"
    #                             sleep 1
    #                     fi
    #                     if [[ $counter_st == 10 ]]; then
    #                             echo -en '                                        \r'
    #                             counter_st=0
    #                             var_waiting_st="starting epad"
    #                     fi
    #                     #echo "in loop"
    #             done
    #             # linecount=$(docker ps -a  | grep healthy | wc -l)
    #             if [[ $linecount_st -lt 4 ]]; then
    #             	echo "one or more container have issues. ePad couldn't start"
    #             else
    #             	echo "epad is ready to browse: http://$var_host"
    #             fi

    }

    wait_for_containers_tobehealthy(){
    	        local var_start_st=$(date +%s)
				local var_end_st=$(($var_start_st + 300))
				#echo "init : $var_start_st "
				#echo "init : $var_end_st "	
                local linecount_st=0
                local counter_st=0
                local var_waiting_st="starting epad"
                #echo -e "${Yellow}process: changing couchdb folder rights : $(remove_backslash_tofolderpath $var_couchdb_location)"
				#echo -e "${Color_Off}" 
				# in linux needs sudo rights let to the user to edit the folder rights
				#cd $var_path/$var_epadDistLocation
				#echo $(pwd)
                #chmod -R 777 $(remove_backslash_tofolderpath $var_couchdb_location)
                #chmod -R 777 "../tmp"
                while [[ $linecount_st -lt 4 ]] && [[ $var_start_st -lt $var_end_st ]]; do
                	#echo "loop started "
                	var_start_st=$(date +%s)
                	#echo "starting time :  $var_start_st " 
                	#echo "end time :  $var_end_st " 
                        counter_st=$(($counter_st + 1))
                        #echo "cntr $counter_st"
                        linecount_st=$(docker ps -a  | grep '\bhealthy\b' | wc -l | awk ' {print $1}')

                        #echo "line count : $linecount_st "
                        if [[ $counter_st > 0 ]]; then
                                var_waiting_st="$var_waiting_st."
                                echo -en "$var_waiting_st\r"
                                sleep 1
                        fi
                        if [[ $counter_st == 10 ]]; then
                                echo -en '                                        \r'
                                counter_st=0
                                var_waiting_st="starting epad"
                        fi
                        #echo "in loop"
                done
                # linecount=$(docker ps -a  | grep healthy | wc -l)
                if [[ $linecount_st -lt 4 ]]; then
                	echo "one or more container have issues. ePad couldn't start"
                else
                	echo "epad is ready to browse: http://$var_host"
                fi
    }

	collect_system_configuration(){
		echo -e "${Yellow}process: collecting system configuration info"
		echo -e "${Color_Off}"
		echo -e "${Purple}!!! IMPORTANT '$' CHARACHTER IS NOT ALLOWED FOR THE INPUT FIELDS !!!"
		echo -e "${Color_Off}"
		var_response=""
		
		#read -p "hostname (default value : $var_host) :" var_response
		askInputLoop "hostname (default value : $var_host) :" var_response ""
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        #var_host=$var_response
                        var_host=$var_response
                        #echo "host name : $var_host"
                fi
                
		#read -p "mode (1) lite (2) thick (default value : $var_mode) :" var_response
		askInputLoop  "mode (1) lite (2) thick (default value : $var_mode) :" var_response "" "1-2"
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        if [[ $var_response == 1 ]]; then
                        	var_mode="lite"
                        elif [[ $var_response == 2 ]]; then
                        	var_mode="thick"
                        else
                        	var_mode="lite"
                        fi
                        #echo "mode : $var_mode"
                fi
        # branch section

        		#read -p "dicomweb branch: (default value : $( remove_backslash_tofolderpath $var_branch_dicomweb)) :" var_response
        		askInputLoop  "dicomweb branch: (default value : $( remove_backslash_tofolderpath $var_branch_dicomweb)) :" var_response ""
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        #var_branch_dicomweb=$var_response
                        var_branch_dicomweb=$( add_backslash_tofolderpath $var_response) 
                        #echo "dicomweb branch : $var_branch_dicomweb"
                fi
        		
        		#read -p "epadlite branch: (default value :$( remove_backslash_tofolderpath $var_branch_epadlite)) :" var_response
        		askInputLoop  "epadlite branch: (default value :$( remove_backslash_tofolderpath $var_branch_epadlite)) :" var_response ""
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        #var_branch_epadlite=$var_response
                        var_branch_epadlite=$( add_backslash_tofolderpath $var_response) 
                        #echo "epadlite branch : $var_branch_epadlite"
                fi
        		
        		#read -p "epadjs branch: (default value : $( remove_backslash_tofolderpath $var_branch_epadjs)) :" var_response
        		askInputLoop "epadjs branch: (default value : $( remove_backslash_tofolderpath $var_branch_epadjs)) :" var_response ""
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        #var_branch_epadjs=$var_response
                        var_branch_epadjs=$( add_backslash_tofolderpath $var_response) 
                        #echo "epadjs branch : $var_branch_epadjs"
                fi
        # branch section
                
		#read -p "configuration (environment (1) or local files (2)) (default value : $var_config) :" var_response
		askInputLoop  "configuration (environment (1) or local files (2)) (default value : $var_config) :" var_response "" "1-2"
		
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        if [[ $var_response == 1 ]]; then
                        	var_config="environment"
                    	elif [[ $var_response == 2 ]]; then
                        	var_config="files"
                    	else
                    		var_config="environment"
                    	fi
                        #echo "config : $var_config"
                fi
		
		#read -p "maria db location (default value : $( remove_backslash_tofolderpath $var_mariadb_location)) :" var_response
		askInputLoop "maria db location (default value : $( remove_backslash_tofolderpath $var_mariadb_location)) :" var_response ""
              	if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        var_mariadb_location=$( add_backslash_tofolderpath $var_response)  
                        #echo "mariadb_location : $( remove_backslash_tofolderpath $var_mariadb_location) "
                fi
		
		#read -p "couch db location (default value :  $( remove_backslash_tofolderpath $var_couchdb_location)) :" var_response
		askInputLoop "couch db location (default value :  $( remove_backslash_tofolderpath $var_couchdb_location)) :" var_response ""
              	if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        var_couchdb_location=$( add_backslash_tofolderpath $var_response)
                        #echo "couchdb location :  $( remove_backslash_tofolderpath $var_couchdb_location) "
                fi
	}

	checkInputForChars (){
		#example for $ char
		# param $1 is for the char that we are looking
		# param $2 is the variable that we will search the special char in
		var_global_specialchar_flag=""
		local localvar_checkchar=""
		localvar_checkchar="$(echo $2 | grep "\\$1")"
		if [[  "$localvar_checkchar" == "" ]];then
			#echo "no spec char found"
			var_global_specialchar_flag=""
		else
			echo -e "\n${Purple}!!! unwanted charachter $1 found please remove or use different charachter"
			echo -e "${Color_Off}"
			var_global_specialchar_flag="set"
		fi

	}
	checkAcceptedChars (){
		#example for $ char
		# param $1 is for the chars that we are accpeting
		# param $2 is the variable that we will search the special char in
		var_global_specialchar_flag=""
		#echo "check accepted chars : $1"
		local localvar_checkchar=""
		localvar_checkchar="$(echo $2 | grep "$1")"
		if [[ "$2" =~ ^[$1]$ ]] ; then
			#echo "no spec char found"
			var_global_specialchar_flag=""
			
		else
			var_global_specialchar_flag="set"
			echo -e "\n${Purple}!!! you need to provide following options as an answer $1"
			echo -e "${Color_Off}"
			#var_global_specialchar_flag=""
		fi

	}
	askInputLoop(){
		# $1 the text
		# $2 the var to return the value if valid
		# $3 the value can be pass. to hide output or to show user 
		# $4 required only chars
		#echo "1: $1 , 2:$2, 3:$3" 
		if [[ "$3" == "pass" ]]; then
			read -s -p "$1" $2
		else
			read -p "$1" $2
		fi
		
		temp=$2
		#echo ${!temp}
		#echo "var_response: $var_response"
		if [[ -z $4 ]];then
			checkInputForChars "$" ${!temp}
		else
			checkAcceptedChars  "$4" ${!temp}
		fi
		while [[ "$var_global_specialchar_flag" == "set" ]]; do
			if [[ "$3" == "pass" ]]; then
				read -s -p "$1" $2
			else
				read -p "$1" $2
			fi
			temp=$2
			if [[ -z $4 ]];then
				checkInputForChars "$" ${!temp}
			else
				checkAcceptedChars  "$4" ${!temp}
			fi
			#echo "$var_response"
		done
	}
	
	collect_user_credentials (){
		
		echo -e "${Yellow}process: collecting user credentials"
		echo -e "${Color_Off}"
		echo -e "${Purple}!!! IMPORTANT '$' CHARACHTER IS NOT ALLOWED FOR THE INPUT FIELDS !!!"
		echo -e "${Color_Off}"
		var_response=""
		var_responsesec=""
		local local_var_checkdolar=""
		 if [[ "$var_keycloak_user" == "YOUR_KEYCLOAK_ADMIN_USER" ]]; then
        	var_keycloak_user="admin"
        fi
        askInputLoop "keycloak user name (default value : $var_keycloak_user) :" var_response ""
        #echo "askInputLoop returning value for var_response : $var_response"
		#read -p "keycloak user name (default value : $var_keycloak_user) :" var_response
		 
		#checkInputForChars "$" $var_response
		#echo "result : $var_global_specialchar_flag"
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        var_keycloak_user="$var_response"
                        #echo "var_keycloak_user : $var_keycloak_user"
                fi

        if [[ "$var_keycloak_pass" == "YOUR_KEYCLOAK_ADMIN_PASS" ]]; then
        	var_keycloak_pass=""
        fi
        var_response="a"
        var_responsesec="b"
        while [ $var_response != $var_responsesec ]
        do 
			#read -s -p "keycloak user password :" var_response
			askInputLoop "keycloak user password :" var_response "pass"
			 printf '\n'
			#read -s -p "retype keycloak user password :" var_responsesec
			askInputLoop "retype keycloak user password :" var_responsesec "pass"
					if [[ -n "$var_response" && -n "$var_responsesec" ]]
	                then
	                	if [[ "$var_response" == "$var_responsesec" ]]
						then
	                        #echo "response = $var_response"
	                        var_keycloak_pass="$var_response"
	                        #echo "var_keycloak_pass : $var_keycloak_pass"
	                    else
	                    	echo -e "${Purple}\npasword doesn't match. please reenter"
	                    	echo -e "${Color_Off}"
	                    fi

	                fi

	        printf '\n'
	    done
        #echo "var_keycloak_pass : $var_keycloak_pass"
		if [[ "$var_keycloak_useremail" == "YOUR_KEYCLOAK_ADMIN_EMAIL" ]]; then
        	var_keycloak_useremail="admin@gmail.com"
        fi
		#read -p "keycloak user email (default value : $var_keycloak_useremail) :" var_response
		askInputLoop "keycloak user email (default value : $var_keycloak_useremail) :" var_response ""
        		if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        var_keycloak_useremail="$var_response"
                        #echo "var_keycloak_useremail : $var_keycloak_useremail"

                fi
        printf '\n'

		if [[ "$var_couchdb_user" == "YOUR_COUCH_ADMIN_USER" ]]; then
        	var_couchdb_user="admin"
        fi
        

		#read -p "couchdb user name (default value : $var_couchdb_user) :" var_response
		askInputLoop "couchdb user name (default value : $var_couchdb_user) :" var_response ""
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        var_couchdb_user="$var_response"
                        #echo "var_couchdb_user : $var_couchdb_user"
                fi

		if [[ "$var_couchdb_pass" == "YOUR_COUCH_ADMIN_PASS" ]]; then
        	var_couchdb_pass=""
        fi
        var_response="a"
        var_responsesec="b"
        while [ $var_response != $var_responsesec ]
        do   
			#read -s -p "couchdb user password :" var_response
			askInputLoop "couchdb user password :" var_response "pass"
			 printf '\n'
			#read -s -p "retype couchdb user password :" var_responsesec
			askInputLoop "retype couchdb user password :" var_responsesec "pass"
					if [[ -n "$var_response" && -n "$var_responsesec" ]]
	                then
	                	if [[ "$var_response" == "$var_responsesec" ]]
						then
	                        #echo "response = $var_response"
	                        var_couchdb_pass="$var_response"
	                        #echo "var_couchdb_pass : $var_couchdb_pass"
	                   	else
	                    	echo -e "${Purple}\npasword doesn't match. please reenter"
	                    	echo -e "${Color_Off}"
	                    fi
	                fi
	        printf '\n'
	    done

		if [[ "$var_maria_user" == "YOUR_DB_USER" ]]; then
        	var_maria_user="admin"
        fi
         printf '\n'
		#read -p "maria db user name (default value : $var_maria_user) :" var_response
		askInputLoop "maria db user name (default value : $var_maria_user) :" var_response ""
                if [[ -n "$var_response" ]]
                then
                        #echo "response = $var_response"
                        var_maria_user="$var_response"
                        #echo "var_maria_user : $var_maria_user"

                fi

		if [[ "$var_maria_pass" == "YOUR_DB_PASS" ]]; then
        	var_maria_pass=""
        fi
        var_response="a"
        var_responsesec="b"
        while [[ "$var_response" != "$var_responsesec" ]]
        do                
			#read -s -p "maria db user password :" var_response
			askInputLoop "maria db user password :" var_response "pass"
			printf '\n'
			#read -s -p "retype maria db user password :" var_responsesec
			askInputLoop "retype maria db user password :" var_responsesec "pass"
	                 if [[ -n "$var_response" && -n "$var_responsesec" ]]
	                then
	                	if [[ "$var_response" == "$var_responsesec" ]]
						then
	                        #echo "response = $var_response"
	                        var_maria_pass="$var_response"
	                        #echo "var_maria_pass : $var_maria_pass"
	                    else
	                    	echo -e "${Purple}\npasword doesn't match. please reenter"
	                    	echo -e "${Color_Off}"
	                    fi
	                fi
			
	        printf '\n'
	    done

		if [[ "$var_maria_rootpass" == "YOUR_DB_ROOT_PASS" ]]; then
        	var_maria_rootpass=""
        fi
         printf '\n'
        var_response="a"
        var_responsesec="b"
        while [ $var_response != $var_responsesec ]
        do
			#read -s -p "maria db root password :" var_response
			askInputLoop "maria db root password :" var_response "pass"
			 printf '\n'
			#read -s -p "retype maria db root password :" var_responsesec
			askInputLoop "retype maria db root password :" var_responsesec "pass"
	                if [[ -n "$var_response" && -n "$var_responsesec" ]]
					then
						if [[ "$var_response" == "$var_responsesec" ]]
						then
	                        #echo "response = $var_response"
	                        var_maria_rootpass="$var_response"
	                        #echo "var_maria_rootpass : $var_maria_rootpass"
	                    else
	                    	echo -e "${Purple}\npasword doesn't match. please reenter"
	                    	echo -e "${Color_Off}"
	                    fi

	                fi

	        printf '\n'
    	done
	}

	edit_epad_yml (){
		echo -e "${Yellow}process: editing epad.yml file"
		echo -e "${Color_Off}"
		sed -i -e "s/host:.*/host: $var_host/g" "$var_path/$var_epadDistLocation/epad.yml"
		#sed -i -e "s/mode:.*/mode: $var_mode/g" "$var_path/$var_epadDistLocation/epad.yml"
		awk -v var_awk="mode: $var_mode" '/mode:.*/{c++; if (c==1) { sub("mode:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"

		sed -i -e "s/config:.*/config: $var_config/g" "$var_path/$var_epadDistLocation/epad.yml"
		#sed -i -e "s/user:.*/user: $var_keycloak_user/g" "$var_path/$var_epadDistLocation/epad.yml"
	    
	    # keycloak 

			    awk -v var_awk="user: $var_keycloak_user" '/user:.*/{c++; if (c==1) { sub("user:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
			    awk -v var_awk="password: $var_keycloak_pass" '/password:.*/{c++; if (c==1) { sub("password:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
				#sed -i -e "s/password:.*/password: $var_keycloak_pass/g" "$var_path/$var_epadDistLocation/epad.yml"
		        sed -i -e "s/email:.*/email: $var_keycloak_useremail/g" "$var_path/$var_epadDistLocation/epad.yml"
		# keycloak end

        #couch db 
        		awk -v var_awk="user: $var_couchdb_user" '/user:.*/{c++; if (c==2) { sub("user:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
        		awk -v var_awk="password: $var_couchdb_pass" '/password:.*/{c++; if (c==2) { sub("password:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        temp_var_couchdb_location=$( add_backslash_tofolderpath $var_couchdb_location)
		                
		        awk -v var_awk="dblocation: \"$temp_var_couchdb_location\" " '/dblocation:.*/{c++; if (c==1) { sub("dblocation:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
			
		# couch db end

        # maria db
		        #sed -i -e "s/pass:.*/pass: $var_maria_pass/g" "$var_path/$var_epadDistLocation/epad.yml"
		        sed -i -e "s/rootpassword:.*/rootpassword: $var_maria_rootpass/g" "$var_path/$var_epadDistLocation/epad.yml"
				awk -v var_awk="user: $var_maria_user" '/user:.*/{c++; if (c==3) { sub("user:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
				awk -v var_awk="password: $var_maria_pass" '/password:.*/{c++; if (c==3) { sub("password:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
				#sed -i -e "s/ARG_EPAD_DOCKER_GID:.*/ARG_EPAD_DOCKER_GID: $var_local_docker_gid/g" "var_path/$var_epadLiteDistLocation/docker-compose.yml"
				
				#setup dblocations
				
				temp_var_mariadb_location=$( add_backslash_tofolderpath $var_mariadb_location) 
				
		        awk -v var_awk="dblocation: \"$temp_var_mariadb_location\" " '/dblocation:.*/{c++; if (c==2) { sub("dblocation:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
        # maria db end


			
        # edit branch part
        temp_var_branch_dicomweb=$( add_backslash_tofolderpath $var_branch_dicomweb) 
        temp_var_branch_epadlite=$( add_backslash_tofolderpath $var_branch_epadlite) 
        temp_var_branch_epadjs=$( add_backslash_tofolderpath $var_branch_epadjs) 
		        awk -v var_awk="branch: \"$temp_var_branch_dicomweb\"" '/branch:.*/{c++; if (c==1) { sub("branch:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        awk -v var_awk="branch: \"$temp_var_branch_epadlite\"" '/branch:.*/{c++; if (c==2) { sub("branch:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        awk -v var_awk="branch: \"$temp_var_branch_epadjs\"" '/branch:.*/{c++; if (c==3) { sub("branch:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        
        #edit branch part end

        # edit port part
		        awk -v var_awk="port: \"$var_keycloak_port\"" '/~port:.*/{c++; if (i==1) { sub("port:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        awk -v var_awk="port: \"$var_couchdb_port\"" '/~port:.*/{c++; if (c==2) { sub("port:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        awk -v var_awk="port: \"$var_dicomweb_port\"" '/~port:.*/{c++; if (c==3) { sub("port:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        awk -v var_awk="port: \"$var_epadlite_port\"" '/~port:.*/{c++; if (c==5) { sub("port:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        awk -v var_awk="port: \"$var_epadjs_port\"" '/~port:.*/{c++; if (c==6) { sub("port:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        awk -v var_awk="port: \"$var_maria_port\"" '/~port:.*/{c++; if (c==6) { sub("port:.*",var_awk) } }1'  "$var_path/$var_epadDistLocation/epad.yml" > "$var_path/$var_epadDistLocation/tempEpad.yml" && mv "$var_path/$var_epadDistLocation/tempEpad.yml"  "$var_path/$var_epadDistLocation/epad.yml"
		        
        #edit port part end
	}

	edit_compose_file(){
		echo -e "${Yellow}process: editing docker-compose file for ARG_EPAD_DOCKER_GID"
		echo -e "${Color_Off}"
		if [[ -z $var_local_docker_gid ]]; then
			echo "docker gid : not found. normal for mac os"
		else
			echo "docker gid : $var_local_docker_gid"
		fi
		sed -i -e "s/ARG_EPAD_DOCKER_GID:.*/ARG_EPAD_DOCKER_GID: $var_local_docker_gid/g" "$var_path/$var_epadLiteDistLocation/docker-compose.yml"
	}


	import_keycloak(){
		local localvar_conres=""
		echo -e "${Yellow}process: importing keycloak users...."
		echo -e "${Color_Off}"
		localvar_conres=$(check_keycloak_container_situation)
		if [[ $localvar_conres != "noop" ]]; then
			local var_full_keycloak_export_path=$var_path$var_keycloak_exportfolder
			if [[ ! -f "$var_full_keycloak_export_path" ]]; then
				echo "$var_full_keycloak_export_path does not exist. You need to export keycloak users first."
				exit 1
			fi
			echo $var_full_keycloak_export_path
			# touch "$var_path/importkeycloak.log"
			#var_import_process=$(docker container top epad_keycloak | grep "keycloak.migration.action" | cut -d" " -f1)
			#echo "$var_import_process"
			#echo "importing keycloak users...."		
			docker exec -i epad_keycloak /opt/jboss/keycloak/bin/standalone.sh \
			-Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=import \
			-Dkeycloak.migration.provider=$var_provider \
			-Dkeycloak.migration.realmName=$var_realmName \
			-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
			-Dkeycloak.migration.file=$var_keycloak_exportfolder > $var_path/importkeycloak.log &
			#echo $! > "$var_path/pid.txt"
	                #echo $!
	               local result=""
	               local resultFail=""
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
		fi
	}

	export_keycloak(){
	 	local localvar_conres=""
		echo -e "${Yellow}process: exporting keycloak users...."
		echo -e "${Color_Off}"
		localvar_conres=$(check_keycloak_container_situation)
			if [[ $localvar_conres != "noop" ]]; then
				docker exec -i epad_keycloak /opt/jboss/keycloak/bin/standalone.sh \
				-Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=export \
				-Dkeycloak.migration.provider=$var_provider \
				-Dkeycloak.migration.realmName=$var_realmName \
				-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
				-Dkeycloak.migration.file=$var_keycloak_exportfolder > exportkeycloak.log  &
				#echo $! > "$var_path/pid.txt"
				#echo $!
		                local result=""
		                local resultFail=""
		                local resultOtherErrors=""
		                while [[ -z $result ]] && [[ -z $resultFail ]]; do
		                        result=$(cat $var_path/exportkeycloak.log | grep "Export finished successfully")

		                        resultFail=$(cat $var_path/exportkeycloak.log | grep "Server boot has failed in an unrecoverable manner")

		                        # resultOtherErrors=$(cat $var_path/exportkeycloak.log | grep "Error")
		                done

		                
		                if [[ $resultFail == *"Server boot has failed in an unrecoverable manner"* ]]; then
		                        echo "$resultFail.  Exiting script...."         
		                        exit 1
		                fi
		                if  [[ $resultOtherErrors == *"Error"* ]]; then
		                	echo "$resultOtherErrors.  Exiting script...."         
		                        exit 1
		                fi

		                echo $result

				echo "restarting keycloak"
		                docker restart epad_keycloak
			fi
	}
		
	show_instructions(){
        echo "you need to provide argument(s) "
        echo "script comands :"

        echo "epad_manage.sh install"
        echo "epad_manage.sh start"
        echo "epad_manage.sh stop"

        echo "epad_manage.sh update epad"
        echo "!!!! update epad: updates hostname, mode, database locations. Does not pull a fresh epad-dist folder from git"
        echo "!!!! update epad: if your epad.yml is outdated, it will force you to get a new epad-dist"
		echo "epad_manage.sh update config"
		echo "!!!! update config: updates everything. Pulls the latest verison of epad-dist folder from git"
		#echo "epad_manage.sh fixip"

		echo "epad_manage.sh export keycloakusers"
		echo "epad_manage.sh import keycloakusers"
	}

# main 
	if [ "$#" -gt 0 ]; then


         if [[ $1 == "test" ]]; then
			echo "test started ----------------------------"
			echo "test finished ---------------------------"
		 fi

		if [[ $1 == "install" ]]; then
			echo -e "${Yellow}process: Installing ePad"
    		echo -e "${Color_Off}"
			var_install_result_r=""
			#create_epad_folders
			check_ifallcontainers_created
			# echo $global_var_container_exist
			if [[  $global_var_container_exist == "exist" ]]; then
				echo -e "${Purple}"
				echo -e "We detected an existing ePad !!!!.\nIMPORTANT!: Reinstalling ePad will delete all images, containers and keycloak users.\nYou need to delete database folders manually \nor You need to make sure to assign previous credentials \nor You need to edit credentials in container manually.\n"
				echo -e "${Color_Off}"
				read -p "Do you want to reinstall ePad? (y/n : default response is n) :"  var_install_result_r 

				
				# echo $var_install_result_r
				 if [[ -z $var_install_result_r  ||   "$var_install_result_r" != "y" ]]; then
                		echo "exiting ePad installation."
                        exit 1
               	else 
               		#cd "$var_path/$var_epadLiteDistLocation"
					#docker-compose down
					#export_keycloak
					remove_epad_images
               		#delete_dangling_images
               		echo "installing epad"
               		var_reinstalling="true"
               	fi
			fi
			echo "epad will be installed in : $var_path"
			copy_epad_dist
			find_host_info
			find_docker_gid
			collect_system_configuration
			collect_user_credentials
			var_refilltheform="n"
			#read -p "Do you want to change your answers ? (y/n) :"  var_refilltheform 
			askInputLoop  "Do you want to change your answers ? (y/n) :" var_refilltheform "" "y|n"
			#echo "var_refilltheform : $var_refilltheform"
			 while [[ "$var_refilltheform" == "y" ]]; do
			 		collect_system_configuration
					collect_user_credentials
					#read -p "Do you want to change your answers ? (y/n) :"  var_refilltheform 
					askInputLoop  "Do you want to change your answers ? (y/n) :" var_refilltheform "" "y|n"
			 done
			edit_epad_yml
			create_epad_folders
			create_epad_lite_dist
			edit_compose_file
			start_containers_viaCompose_all
			# if [[  $global_var_container_exist == "exist" ]]; then
			# 	if [[ ! -z $var_install_result_r  ||   "$var_install_result_r" == "y" ]]; then
			#		update_mariadb_usersandpass
			#	fi
			#fi
			wait_for_containers_tobehealthy
			# if [[  $global_var_container_exist == "exist" ]]; then
			#	if [[ ! -z $var_install_result_r  ||   "$var_install_result_r" == "y" ]]; then
			#		import_keycloak
			#	fi
			#fi
			check_container_situation

			# reset global variables
			global_var_container_exist=""
			var_reinstalling="false"

		fi

        if [[ $1 == "start" ]]; then
        	echo -e "${Yellow}process: Starting ePad"
    		echo -e "${Color_Off}"

			load_credentials_tovar
			#var_host=$( find_val_intext "host:" "1")
			doublecheck_ipmapping_onstart
			check_ifallcontainers_created
			if [[ ! $global_var_container_exist=="exist" ]]; then
				echo "you have missing containers. Please reinstall ePad."
				exit 1
			fi
			start_containers_all
			check_container_situation
			# reset global variables
			global_var_container_exist=""
        fi

        if [[ $1 == "stop" ]]; then
        	echo -e "${Yellow}process: Stopping ePad"
    		echo -e "${Color_Off}"
        	check_ifallcontainers_created
        	if [[ ! $global_var_container_exist=="exist" ]]; then
				echo "you have missing containers. Please reinstall ePad."
				exit 1
			fi
            stop_containers_all
			# reset global variables
			global_var_container_exist=""
        fi
 		
		if [[ $1 == "fixip" ]]; then
    			echo -e "${Yellow}process: fixing your computer ip"
    			echo -e "${Color_Off}"
    			echo "Please use epad_fixmyip.sh script whcih is located in epad-dist folder."

        fi
		
		if [[ $1 == "update" ]]; then
            
            if [[ $2 == "epad" ]]; then
				echo -e "${Yellow}process: updating epad"
				echo -e "${Color_Off}"
				parse_yml_sections
				var_ymlupdate=$(check_epadyml_needs_update)
				if [[ "$var_ymlupdate" == "pull" ]]; then
					echo "We detected an old epad.yml. Please use update config to update ePad. Operation cancelled."
					exit 1
				fi
				export_keycloak
				remove_epad_images
				load_credentials_tovar
				find_host_info
				find_docker_gid
				collect_system_configuration
					var_refilltheform="n"
					read -p "Do you want to change your answers ? (y/n) :"  var_refilltheform 
					echo "var_refilltheform : $var_refilltheform"
					 while [[ "$var_refilltheform" == "y" ]]; do
					 		collect_system_configuration
							read -p "Do you want to change your answers ? (y/n) :"  var_refilltheform 
					 done
				edit_epad_yml
                create_epad_lite_dist
                edit_compose_file
				build_images_via_nocache
				start_containers_viaCompose_all
				wait_for_containers_tobehealthy
				import_keycloak
				check_container_situation
			elif [[ $2 == "config" ]]; then
				# only update config updates epad-dist from git 
				echo -e "${Yellow}process: updating epad configuration "
				echo -e "${Color_Off}"
				export_keycloak
				#stop_containers_all
				#remove_containers_all
				remove_epad_images
				#cd "$var_path/$var_epadLiteDistLocation"
				#docker-compose build --no-cache
				load_credentials_tovar
				# added in case epad.yml and .config has changes
				copy_epad_dist
				find_host_info
				find_docker_gid
				# end added in case epad.yml and .config has changes
                collect_system_configuration
                collect_user_credentials
                	var_refilltheform="n"
					read -p "Do you want to change your answer ? (y/n) :"  var_refilltheform 
					echo "var_refilltheform : $var_refilltheform"
					 while [[ "$var_refilltheform" == "y" ]]; do
					 		collect_system_configuration
					 		collect_user_credentials
							read -p "Do you want to change your answer ? (y/n) :"  var_refilltheform 
					 done
                edit_epad_yml
                create_epad_lite_dist
				edit_compose_file
				build_images_via_nocache
				start_containers_viaCompose_all
				update_mariadb_usersandpass
				wait_for_containers_tobehealthy
				import_keycloak
				check_container_situation
			else
				show_instructions
			fi
			
       	fi
# export import keycloak part
		if [[ $1 == "export" ]]; then
               
                if [[ $2 == "keycloakusers" ]]; then
                	echo -e "${Yellow}process: exporting keycloak users "
                	echo -e "${Color_Off}"
                        export_keycloak
                fi

         fi

        if [[ $1 = "import" ]]; then
                    
                if [[ $2 == "keycloakusers" ]]; then
                	echo -e "${Yellow}process: importing keycloak users "
					echo -e "${Color_Off}"
                        import_keycloak
                fi

        fi
# epxport import keycloak part end


	else
		show_instructions
	fi
