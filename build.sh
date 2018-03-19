#! /bin/bash

PACKER=$(which packer)
[[ -z ${PACKER} ]] &&  echo 'packer command not found in the search path. exiting...' && exit 1

if [ -z ${ANSIBLE_VAULT_PASSWORD+x} ]; then echo "ANSIBLE_VAULT_PASSWORD not set"; else echo "${ANSIBLE_VAULT_PASSWORD}" > .vault_pass.txt; fi

${PACKER} build -var "london_vpc_id=${LONDON_VPC}" -var "london_subnet_id=${LONDON_SUBNET}" -var "ireland_vpc_id=${IRELAND_VPC}" -var "ireland_subnet_id=${IRELAND_SUBNET}" ubuntu.json