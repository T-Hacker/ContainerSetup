#!/bin/bash

#############################
# Recreate Docker container #
# 26 Abr 2026               #
#############################

# Globals
DEBUG=1
dockerid=$(docker ps | grep $USER | awk '{print $1;}')

# Aux Functions
function log() {
	if [ $DEBUG -ne 0 ]; then
		echo $1
	fi
}

function check_success() {
	if [ $? -ne 0 ]; then
		echo $1
		exit 1
	fi
}

log "Stop Docker container"
docker stop $dockerid
check_success "Error stopping container"

# Update code
log "Update MN common repo"
cd /var/work/$USER/common
git pull --rebase origin master
check_success "Error pull common"
cd -

log "Update l1sw repo"
cd /var/work/$USER/l1sw
git pull --rebase --recurse-submodules origin master
check_success "Error pull l1sw"
cd -

log "Check Artifactory keys"
/var/work/m1martin/common/tools/store_artifactory_host_keys.py
check_success "Error on common keys"

log "Start container"
cd /var/work/$USER/l1sw
make env L1SW_SSH=ON
dockerid=$(docker ps | grep $USER | awk '{print $1;}')
check_success "Error creating container"
cd -

log "Copy container script"
docker cp ./setup_container_env.sh $dockerid:/home/$USER/
check_success "Error copying the script to container"

log "Execute the script on container"
docker exec -it --user $USER $dockerid sh -c "/home/$USER/setup_container_env.sh && source ~/.bashrc"
check_success "Error executing the script on the container"

echo "Done!"
exit 0
