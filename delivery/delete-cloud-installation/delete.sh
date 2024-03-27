#!/bin/bash

set -u
set -e
set -o pipefail

source ${GITHUB_ACTION_PATH}/log.sh

INFO Constructing cloud command ...
CMD=("cloud installation delete")
CMD_ARGS=("--server ${PROVISIONER_SERVER}")
CMD_ARGS+=("--installation ${INSTALLATION_ID}")

if [ -n "${PROVISIONER_HEADERS}" ]; then
  while IFS= read -r header; do
    CMD_ARGS+=("--header ${header}")
  done <<< "${PROVISIONER_HEADERS}"
fi

FINAL_COMMAND="${CMD[@]} ${CMD_ARGS[@]}"
INFO "Executing command -> ${FINAL_COMMAND}"
CLOUD_COMMAND_OUTPUT=$(eval "${FINAL_COMMAND}")
CLOUD_COMMAND_EXIT_CODE=$?
if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
  ERROR Cloud installation deletion failed with error: ${CLOUD_COMMAND_OUTPUT}
  exit ${CLOUD_COMMAND_EXIT_CODE}
fi

OK "Cloud installation ${INSTALLATION_ID} deleted"

