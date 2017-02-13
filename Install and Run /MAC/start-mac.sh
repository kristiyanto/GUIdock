#!/bin/bash


# The IP address is the Mac IP Brigde IP Address. 
# Use command:
# 		VBoxManage list bridgedifs
# if you are unsure about the address.

export MacIP="192.168.99.1"
export DockerMachine=$(docker-machine ls | awk 'FNR == 2 {print $1}')

# This script works with other Docker Images.
if [ $# -eq 0 ]
  then
	export DockerImage="kristiyanto/guidock"
	else
	export DockerImage=$1
fi


# Look for available Docker Machine.
if [ -z $DockerMachine ] 
	then
	echo "Docker Machine is not found. Please check if Docker is properly Installed."
	echo "Script will now exit."
	exit 1
	else
	echo Launching $DockerImage on $DockerMachine
fi

# Script starts here ---
docker-machine start $DockerMachine
echo "Launching Socat to bind X11 services to port 6000."

socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" & > /dev/null

echo "Launching XQuartz"
open -a xquartz &
echo "Setting up environtment"
eval $(docker-machine env $DockerMachine)
docker pull $DockerImage
docker run -ti -e DISPLAY=$MacIP:0 -e JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ $DockerImage
