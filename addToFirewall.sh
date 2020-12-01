#!/bin/bash
echo "This script support only CentOs for now. If your os is different please add docker interface manually to your firewall trusted zone and restart docker."
echo "You can collect ePad docker network interface via docker inspect epad_lite --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' command"

read -p "The script will add docker ePad network to your server trusted zone. Do you want to continue? (y/n) : " response

check_operating_system(){
	local localvar_osname=""
	echo "Checking your operating system..."
	localvar_osname=$(cat /etc/os-release | grep "^NAME=" | cut -d"=" -f2)
	if [[ -n $(echo $localvar_osname | grep "CentOs") ]]; then
		echo "your os : $localvar_osname
		updating firewall settings.
	else
		echo "your operating system \" $localvar_osname \" is not supported yet. Exiting. "
		exit 1
	fi
}

if [[ $response = "y" ]]; then
	check_operating_system
	networkID=$(docker inspect epad_lite --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}')
	firewall-cmd --permanent --zone=trusted --add-interface="$networkID"
	firewall-cmd --reload 
	systemctl restart docker 
fi

