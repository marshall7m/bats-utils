#!/bin/bash
source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../node_modules/bash-utils/load.bash"

clone_repo() {
	log "FUNCNAME=$FUNCNAME" "DEBUG"

    if [ "${#@}" -ne 2 ]; then
        log "Missing params" "ERROR"
        exit 1
    fi
    
	local clone_url=$1
	local clone_destination=$2

	if [ -z "$clone_destination" ]; then
		log "\$2 for git clone destination is not set" "ERROR"
		exit 1
	fi

	local_clone_git=$clone_destination/.git

	if [ ! -d $local_clone_git ]; then
		git clone "$clone_url" "$clone_destination"
	else
		log ".git already exists in clone destination" "INFO"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clone_repo "$@"
fi