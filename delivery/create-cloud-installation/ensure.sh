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

DESIRED_STATE="stable" 
BACKOFF_SECONDS=10
TIMEOUT_SECONDS=300

INFO Constructing cloud command ...

CMD=("cloud installation get")
CMD_ARGS=("--server \"${PROVISIONER_SERVER}\"")
CMD_ARGS+=("--header \"Authorization=Bearer ${TOKEN}\"")

if [ -n "${PROVISIONER_HEADERS}" ]; then
  while IFS= read -r header; do
    CMD_ARGS+=("--header ${header}")
  done <<< "${PROVISIONER_HEADERS}"
fi

CMD_ARGS+=("--installation ${INSTALLATION_ID}")

FINAL_COMMAND="${CMD[@]} ${CMD_ARGS[@]}"
INFO "Executing command -> ${FINAL_COMMAND}"
INFO "Waiting for ${DESIRED_STATE} state"

CLOUD_STATE=${INITIAL_STATE}
LOOP_COUNT=0
until [ ${CLOUD_STATE} == ${DESIRED_STATE} ]; do

  if [ $(( LOOP_COUNT * BACKOFF_SECONDS )) -eq ${TIMEOUT_SECONDS} ]; then
    WARN "Last state was ${CLOUD_STATE} for ${INSTALLATION_ID}"
    ERROR "Cloud installation could not be validated within the ${TIMEOUT_SECONDS} seconds timeout"
    exit 1
  fi

  INFO "Checking for cloud installation ${INSTALLATION_ID} state ... "
  CLOUD_COMMAND_OUTPUT=$(eval "${FINAL_COMMAND}")
  CLOUD_COMMAND_EXIT_CODE=$?
  if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
    ERROR "Could not fetch status for cloud installation ${INSTALLATION_ID}. Failed with error: ${CLOUD_COMMAND_OUTPUT}"
    exit ${CLOUD_COMMAND_EXIT_CODE}
  fi
  CLOUD_STATE=$(echo "${CLOUD_COMMAND_OUTPUT}" | jq --raw-output .State)
  INFO "Cloud installation ${INSTALLATION_ID} is in ${CLOUD_STATE} state ... "

  INFO "Checking again for state in ${BACKOFF_SECONDS} seconds ... "
  sleep ${BACKOFF_SECONDS}

  LOOP_COUNT=$((LOOP_COUNT+1))
done


OK "Cloud installation ${INSTALLATION_ID} is ready"

INFO "Generating Outputs"
CMD=("cloud cluster installation list")
CMD_ARGS=("--server ${PROVISIONER_SERVER}")
CMD_ARGS+=("--header \"Authorization=Bearer ${TOKEN}\"")

if [ -n "${PROVISIONER_HEADERS}" ]; then
  while IFS= read -r header; do
    CMD_ARGS+=("--header ${header}")
  done <<< "${PROVISIONER_HEADERS}"
fi

CMD_ARGS+=("--installation \"${INSTALLATION_ID}\"")

FINAL_COMMAND="${CMD[@]} ${CMD_ARGS[@]}"
INFO "Executing command -> ${FINAL_COMMAND}"
CLOUD_COMMAND_OUTPUT=$(eval "${FINAL_COMMAND}")
CLOUD_COMMAND_EXIT_CODE=$?
if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
  ERROR "Could not fetch id for cluster installation of ${INSTALLATION_ID}. Failed with error: ${CLOUD_COMMAND_OUTPUT}"
  exit ${CLOUD_COMMAND_EXIT_CODE}
fi

echo "id=$(echo "${CLOUD_COMMAND_OUTPUT}" | jq .[0].ID --raw-output)" >> ${GITHUB_OUTPUT}

OK "All Done"