#!/bin/bash
var_os_type=""
var_ip=""
var_host=""

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
		echo $var_ip
	}

	edit_hosts_file(){
	echo "process: editing /etc/hosts"
 		
		var_res=$(cat /etc/hosts | grep $var_ip)
		echo $var_res
        if [ -z "$var_res" ]; then
            echo "ip not found we are adding $var_ip $var_host in your /etc/hosts file"
			echo "$var_ip $var_host" >> /etc/hosts
        else
            #echo "$var_res is already in etc"
			var_res_epadvm=$( echo $var_res | grep "\bepadvm\b"  )
			echo "checking if epadvm is in /etc/hosts "
			#echo $var_res_epadvm
			if [ -z "$var_res_epadvm" ]; then
				echo "$var_res : your ip is mapped to a different name or it is not mapped to a name"
				var_host=$( echo $var_res | awk '{print $2}' )
				#echo $var_host
				if [ -z "$var_host" ]; then
					var_host="epadvm"
					sed -i -e "s/$var_ip/$var_ip $var_host/g" "/etc/hosts"
					if [  -f "/etc/hosts-e" ]; then
						rm /etc/hosts-e
					fi
					#echo "$var_ip $var_host" >> /etc/hosts
					echo "your host name is set to $var_host"
					
				else
					echo "your host name is set to $var_host"
				fi
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

# main
fix_server_via_hosts