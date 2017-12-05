#!/usr/bin/env bash

# Just run the playbook, defaults to localhost inventory
# To specify another inventory, pass it in as the first argument, e.g.:
# ./run.me ~/my_inventory

DIR="$(dirname "$(readlink -f "${0}")")"
INVENTORY="${1:-${DIR}/inventory/hosts.yml}"
export ANSIBLE_CONFIG="${DIR}/ansible.cfg"

if [[ ! -f "${INVENTORY}" ]] ; then
	echo "Inventory not found."
	exit 1
fi

# Check for dependencies
if ! type ansible-playbook &>/dev/null ; then
	read -r -p "Ansible missing, install it? [y/N]: " answer
	if [[ "${answer,,}" != "y" && "${answer,,}" != "yes" ]] ; then
		echo "OK, please install it and retry."
		exit 1
	fi
	echo sudo dnf -y install ansible
	if ! sudo dnf -y install ansible; then
		echo "Something went wrong, sorry."
		exit 1
	fi
fi

echo -e "Using inventory at:\\n${INVENTORY}"

exec ansible-playbook \
	--ask-become-pass \
	--inventory "${INVENTORY}" \
	"${DIR}"/korora.yml

