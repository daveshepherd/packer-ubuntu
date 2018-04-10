#! /bin/bash

PACKER=$(which packer)
[[ -z ${PACKER} ]] &&  echo 'packer command not found in the search path. exiting...' && exit 1

if [ -z ${ANSIBLE_VAULT_PASSWORD+x} ]; then echo "ANSIBLE_VAULT_PASSWORD not set"; else echo "${ANSIBLE_VAULT_PASSWORD}" > .vault_pass.txt; fi

${PACKER} build -var "region=${REGION}" -var "vpc_id=${VPC_ID}" -var "subnet_id=${SUBNET_ID}" -var "destination_regions=${DESTINATION_REGIONS}" build.json