#!/usr/bin/env sh
#

USERS_JSON=${1:-"users/users.json"} 
USER_TEMPLATE=${2:-"users/user.yaml.example"}
OUTPUT_DIRECTORY=${3:-$PWD/templates/rbac}

check_deps() {
  for DEP in jq base64 envsubst
  do
    command -v ${DEP} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Missing required dependency: \"${DEP}\""
      exit 127
    fi
  done
}

validate_json() {
  cat ${USERS_JSON} | jq . > /dev/null 2>&1
  if [ $? -ne 0 ]; then 
    echo "Invalid users JSON file: \"${USERS_JSON}\""
    exit 2
  fi
}

validate_io() {
  if [ ! -f ${USERS_JSON} ]; then
    echo "Missing user JSON file: \"${USERS_JSON}\""
    exit 2
  fi
  if [ ! -f ${USER_TEMPLATE} ]; then
    echo "Missing user template file: \"${USER_TEMPLATE}\""
    exit 2
  fi
  if [ ! -d ${OUTPUT_DIRECTORY} ]; then
    echo "Missing output directory: \"${OUTPUT_DIRECTORY}\""
    exit 2
  fi
}

create_users() {
  for USER in $( cat "${USERS_JSON}" | jq -r '.[] | @base64'); do
    USERNAME=$(echo ${USER} | base64 --decode | jq -r .username)
    PASSWORD=$(echo ${USER} | base64 --decode | jq -r .password)
    export $(echo ${USER} | base64 --decode | jq -r '@sh "PASSWORD_HASH=\(.password_hash)"')
    echo "Generating user template: ${OUTPUT_DIRECTORY}/${USERNAME}.yaml"
    envsubst < ${USER_TEMPLATE} > ${OUTPUT_DIRECTORY}/${USERNAME}.yaml
  done
}

check_deps
validate_io
validate_json
create_users
