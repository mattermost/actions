#!/bin/bash

set -u
set -e
set -o pipefail

source ${GITHUB_ACTION_PATH}/log.sh

INFO "Fetching provisioner token..."
TOKEN_RESPONSE=$(curl --silent --location "${PROVISIONER_TOKEN_URL}" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode "client_id=${PROVISIONER_CLIENT_ID}" \
  --data-urlencode "client_secret=${PROVISIONER_CLIENT_SECRET}" \
  --data-urlencode 'scope=offline_access api://provisioner/.default')

TOKEN=$(echo "${TOKEN_RESPONSE}" | jq --raw-output .access_token)
if [ -z "${TOKEN}" ] || [ "${TOKEN}" == "null" ]; then
  ERROR "Failed to retrieve provisioner token"
  ERROR "Response: ${TOKEN_RESPONSE}"
  exit 1
fi
INFO "Successfully retrieved provisioner token"

INFO Constructing cloud commands ...
CMD=("cloud cluster installation mmctl")
CMD_ARGS=("--server ${PROVISIONER_SERVER}")
CMD_ARGS+=("--header \"Authorization=Bearer ${TOKEN}\"")

if [ -n "${PROVISIONER_HEADERS}" ]; then
  while IFS= read -r header; do
    CMD_ARGS+=("--header ${header}")
  done <<< "${PROVISIONER_HEADERS}"
fi

CMD_ARGS+=("--cluster-installation \"${CLUSTER_INSTALLATION_ID}\"")

CREATE_USER_ARGS=("--command \"user create --local --disable-welcome-email --system-admin --email-verified --email admin@example.com --username ${MM_INIT_USERNAME} --password ${MM_INIT_PASSWORD}\"")
CREATE_TEAM_ARGS=("--command \"team create --local --name ad-1 --display-name ad-1 --email admin@example.com\"")
ADD_USER_TO_TEAM_ARGS=("--command \"team users add ad-1 admin --local\"")

CREATE_USER_COMMAND="${CMD[@]} ${CMD_ARGS[@]} ${CREATE_USER_ARGS[@]}"
CREATE_TEAM_COMMAND="${CMD[@]} ${CMD_ARGS[@]} ${CREATE_TEAM_ARGS[@]}"
ADD_USER_TO_TEAM_COMMAND="${CMD[@]} ${CMD_ARGS[@]} ${ADD_USER_TO_TEAM_ARGS[@]}"

INFO "Executing command -> ${CREATE_USER_COMMAND}"
CLOUD_COMMAND_OUTPUT=$(eval "${CREATE_USER_COMMAND}")
CLOUD_COMMAND_EXIT_CODE=$?
if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
  ERROR User creation failed with error: ${CLOUD_COMMAND_OUTPUT}
  exit ${CLOUD_COMMAND_EXIT_CODE}
fi

INFO "Executing command -> ${CREATE_TEAM_COMMAND}"
CLOUD_COMMAND_OUTPUT=$(eval "${CREATE_TEAM_COMMAND}")
CLOUD_COMMAND_EXIT_CODE=$?
if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
  ERROR Team creation failed with error: ${CLOUD_COMMAND_OUTPUT}
  exit ${CLOUD_COMMAND_EXIT_CODE}
fi

INFO "Executing command -> ${ADD_USER_TO_TEAM_COMMAND}"
CLOUD_COMMAND_OUTPUT=$(eval "${ADD_USER_TO_TEAM_COMMAND}")
CLOUD_COMMAND_EXIT_CODE=$?
if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
  ERROR Adding user to team failed with error: ${CLOUD_COMMAND_OUTPUT}
  exit ${CLOUD_COMMAND_EXIT_CODE}
fi

echo "username=${MM_INIT_USERNAME}" >> ${GITHUB_OUTPUT}
echo "password=${MM_INIT_PASSWORD}" >> ${GITHUB_OUTPUT}

OK "All Done"