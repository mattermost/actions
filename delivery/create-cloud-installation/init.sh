#!/bin/bash

set -u
set -e
set -o pipefail

source ${GITHUB_ACTION_PATH}/log.sh

INFO Constructing cloud commands ...
CMD=("cloud cluster installation mmctl")
CMD_ARGS=("--server ${PROVISIONER_SERVER}")

if [ -n "${PROVISIONER_HEADERS}" ]; then
  while IFS= read -r header; do
    CMD_ARGS+=("--header ${header}")
  done <<< "${PROVISIONER_HEADERS}"
fi

CMD_ARGS+=("--cluster-installation ${CLUSTER_INSTALLATION_ID}")

CREATE_USER_ARGS=("--command \"user create --local --disable-welcome-email --system-admin --email-verified --email admin@example.com --username ${MM_INIT_USERNAME} --password ${MM_INIT_PASSWORD}\"")
CREATE_TEAM_ARGS=("--command \"team create --local --name main --display-name DeliveryTeamCMT --email admin@example.com\"")
ADD_USER_TO_TEAM_ARGS=("--command \"team users add main admin --local\"")

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