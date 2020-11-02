#!/bin/bash
var_os_type=""
var_ip=""
var_host="epadvm"
var_backup=0

	find_os_type(){

	echo "process: finding os type"
            if [[ $OSTYPE == "linux"* ]]; then
                    var_os_type="linux"
            elif  [[ $OSTYPE == "darwin"* ]]; then
                    var_os_type="mac"
            else
                    echo " your operating system is not supported or ostype env variable is not defined. Only linux and macs are supported "i
                    exit 1
            fi
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
		# echo $var_ip
	}

	edit_hosts_file(){
	echo "process: editing /etc/hosts"
	echo "backing up /etc/hosts file"
 		local totalfiles=0
 		totalfiles=$(ls /etc/hosts* | wc -l | awk ' {print $1}')
 		totalfiles=$(($totalfiles + 1))
 		cp /etc/hosts /etc/hosts_epad_backup_$totalfiles
		local var_res=$(cat /etc/hosts | grep "\b$var_ip\b")
		local var_res_host=$(cat /etc/hosts | grep "\b$var_host\b")
		# echo $var_res
		# echo $var_res_host
        if [[ -z "$var_res" ]]; then
        	if [[ -z "$var_res_host" ]]; then
            	echo "ip and epadvm not found in /etc/hosts we are adding $var_ip $var_host in your /etc/hosts file"
				echo "$var_ip $var_host" >> /etc/hosts
			else
				echo "epadvm found in /etc/hosts but with different ip. remapping $var_ip $var_host in your /etc/hosts file"
				sed -i -e "s/*$var_host*/$var_ip $var_host/g" "/etc/hosts"
			fi
        else
            # echo "$var_res is already in etc"
			var_res_epadvm=$( cat /etc/hosts | grep "\bepadvm\b"  )
			echo "checking if epadvm is in /etc/hosts "
			#echo $var_res_epadvm
			if [ -z "$var_res_epadvm" ]; then
				echo "ip found but we couldn't find epadvm in /etc/hosts. $var_ip epadvm mapping will be added "
				echo "$var_ip $var_host" >> /etc/hosts



				# var_host=$( echo $var_res | awk '{print $2}' )
				# #echo $var_host
				# if [ -z "$var_host" ]; then
				# 	var_host="epadvm"
				# 	sed -i -e "s/$var_ip/$var_ip $var_host/g" "/etc/hosts"
				# 	if [  -f "/etc/hosts-e" ]; then
				# 		rm /etc/hosts-e
				# 	fi
				# 	#echo "$var_ip $var_host" >> /etc/hosts
				# 	echo "your host name is set to $var_host"
					
				# else
				# 	echo "your host name is set to $var_host"
				# fi



			fi
        fi
		
	}

	fix_server_via_hosts(){
		# echo "process: fixing server hostname via /etc/hosts "
		var_host="epadvm"
		find_ip	
		edit_hosts_file
		# echo "after fixing etc/hosts $var_host"
		# echo $var_host
	}

# main
fix_server_via_hosts