#!/bin/bash

set -u
set -e
set -o pipefail

source ${GITHUB_ACTION_PATH}/log.sh

INFO Constructing cloud command ...
CMD=("cloud installation create")
CMD_ARGS=("--server ${PROVISIONER_SERVER}")

if [ -n "${PROVISIONER_HEADERS}" ]; then
  while IFS= read -r header; do
    CMD_ARGS+=("--header ${header}")
  done <<< "${PROVISIONER_HEADERS}"
fi

CMD_ARGS+=("--dns ${INSTALLATION_DNS}")
CMD_ARGS+=("--version ${MM_VERSION}")

if [ -n "${MM_LICENCE}" ]; then
  CMD_ARGS+=("--licence ${MM_LICENCE}")
fi

if [ -n "${MM_IMAGE}" ]; then
  CMD_ARGS+=("--image ${MM_IMAGE}")
fi

if [ -n "${INSTALLATION_SIZE}" ]; then
  CMD_ARGS+=("--size ${INSTALLATION_SIZE}")
fi

if [ -n "${INSTALLATION_OWNER}" ]; then
  CMD_ARGS+=("--owner ${INSTALLATION_OWNER}")
fi

if [ -n "${INSTALLATION_NAME}" ]; then
  CMD_ARGS+=("--name ${INSTALLATION_NAME}")
fi

if [ -n "${INSTALLATION_GROUP}" ]; then
  CMD_ARGS+=("--group ${INSTALLATION_GROUP}")
fi

if [ -n "${INSTALLATION_AFFINITY}" ]; then
  CMD_ARGS+=("--affinity ${INSTALLATION_AFFINITY}")
fi

if [ -n "${INSTALLATION_DATABASE}" ]; then
  CMD_ARGS+=("--database ${INSTALLATION_DATABASE}")
fi

if [ -n "${INSTALLATION_FILESTORE}" ]; then
  CMD_ARGS+=("--filestore ${INSTALLATION_FILESTORE}")
fi

if [ -n "${INSTALLATION_ANNOTATIONS}" ]; then
  IFS=',' read -ra installationAnnotations <<< "${INSTALLATION_ANNOTATIONS}"
  for installationAnnotation in "${installationAnnotations[@]}"; do
    CMD_ARGS+=("--annotation ${installationAnnotation}")
  done
fi

if [ -n "${INSTALLATION_GROUP_SELECTION_ANNOTATIONS}" ]; then
  IFS=',' read -ra installationGroupSelectionAnnotations <<< "${INSTALLATION_GROUP_SELECTION_ANNOTATIONS}"
  for installationGroupSelectionAnnotation in "${installationGroupSelectionAnnotations[@]}"; do
    CMD_ARGS+=("--group-selection-annotation ${installationGroupSelectionAnnotation}")
  done
fi

if [ -n "${MM_ENV}" ]; then
  while IFS= read -r envVar; do
    CMD_ARGS+=("--mattermost-env ${envVar}")
  done <<< "${MM_ENV}"
fi

if [ -n "${MM_PRIORITY_ENV}" ]; then
  while IFS= read -r priorityEnvVar; do
    CMD_ARGS+=("--priority-env ${priorityEnvVar}")
  done <<< "${MM_PRIORITY_ENV}"
fi

FINAL_COMMAND="${CMD[@]} ${CMD_ARGS[@]}"
INFO "Executing command -> ${FINAL_COMMAND}"
CLOUD_COMMAND_OUTPUT=$(eval "${FINAL_COMMAND}")
CLOUD_COMMAND_EXIT_CODE=$?
if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
  ERROR Cloud installation creation failed with error: ${CLOUD_COMMAND_OUTPUT}
  exit ${CLOUD_COMMAND_EXIT_CODE}
fi

INSTALLATION_ID=$(echo "${CLOUD_COMMAND_OUTPUT}" | jq --raw-output .ID)
INSTALLATION_STATE=$(echo "${CLOUD_COMMAND_OUTPUT}" | jq --raw-output .State)
INFO "Cloud installation ${INSTALLATION_ID} requested ... "

INFO "Generating Outputs"
echo "id=${INSTALLATION_ID}" >> ${GITHUB_OUTPUT}
echo "state=${INSTALLATION_STATE}" >> ${GITHUB_OUTPUT}

OK "All Done"