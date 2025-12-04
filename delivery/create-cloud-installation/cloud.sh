#!/bin/bash

set -u
set -e
set -o pipefail

source ${GITHUB_ACTION_PATH}/log.sh

INFO "Fetching Azure AD token..."
TOKEN_RESPONSE=$(curl --silent --location "${AZURE_TOKEN_URL}" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode "client_id=${AZURE_CLIENT_ID}" \
  --data-urlencode "client_secret=${AZURE_CLIENT_SECRET}" \
  --data-urlencode 'scope=offline_access api://provisioner/.default')

TOKEN=$(echo "${TOKEN_RESPONSE}" | jq --raw-output .access_token)
if [ -z "${TOKEN}" ] || [ "${TOKEN}" == "null" ]; then
  ERROR "Failed to retrieve Azure AD token"
  ERROR "Response: ${TOKEN_RESPONSE}"
  exit 1
fi
INFO "Successfully retrieved Azure AD token"

INFO Constructing cloud command ...
CMD=("cloud installation create")
CMD_ARGS=("--server \"${PROVISIONER_SERVER}\"")
CMD_ARGS+=("--header \"Authorization=Bearer ${TOKEN}\"")

if [ -n "${PROVISIONER_HEADERS}" ]; then
  while IFS= read -r header; do
    CMD_ARGS+=("--header ${header}")
  done <<< "${PROVISIONER_HEADERS}"
fi

CMD_ARGS+=("--dns \"${INSTALLATION_DNS}\"")
CMD_ARGS+=("--version \"${MM_VERSION}\"")

if [ -n "${MM_LICENSE}" ]; then
  CMD_ARGS+=("--license \"${MM_LICENSE}\"")
fi

if [ -n "${MM_IMAGE}" ]; then
  CMD_ARGS+=("--image \"${MM_IMAGE}\"")
fi

if [ -n "${INSTALLATION_SIZE}" ]; then
  CMD_ARGS+=("--size \"${INSTALLATION_SIZE}\"")
fi

if [ -n "${INSTALLATION_OWNER}" ]; then
  CMD_ARGS+=("--owner \"${INSTALLATION_OWNER}\"")
fi

if [ -n "${INSTALLATION_GROUP}" ]; then
  CMD_ARGS+=("--group \"${INSTALLATION_GROUP}\"")
fi

if [ -n "${INSTALLATION_AFFINITY}" ]; then
  CMD_ARGS+=("--affinity \"${INSTALLATION_AFFINITY}\"")
fi

if [ -n "${INSTALLATION_DATABASE}" ]; then
  CMD_ARGS+=("--database \"${INSTALLATION_DATABASE}\"")
fi

if [ -n "${INSTALLATION_FILESTORE}" ]; then
  CMD_ARGS+=("--filestore \"${INSTALLATION_FILESTORE}\"")
fi

if [ -n "${INSTALLATION_ANNOTATIONS}" ]; then
  IFS=',' read -ra installationAnnotations <<< "${INSTALLATION_ANNOTATIONS}"
  for installationAnnotation in "${installationAnnotations[@]}"; do
    CMD_ARGS+=("--annotation \"${installationAnnotation}\"")
  done
fi

if [ -n "${INSTALLATION_GROUP_SELECTION_ANNOTATIONS}" ]; then
  IFS=',' read -ra installationGroupSelectionAnnotations <<< "${INSTALLATION_GROUP_SELECTION_ANNOTATIONS}"
  for installationGroupSelectionAnnotation in "${installationGroupSelectionAnnotations[@]}"; do
    CMD_ARGS+=("--group-selection-annotation \"${installationGroupSelectionAnnotation}\"")
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

# Capture both stdout and stderr
INFO "Checking if 'cloud' command is available..."
if ! command -v cloud &> /dev/null; then
  ERROR "'cloud' command not found in PATH. Please ensure the cloud CLI is installed."
  ERROR "PATH: ${PATH}"
  exit 1
fi

INFO "Executing cloud installation create command..."
# Temporarily disable exit on error to capture output properly
set +e
CLOUD_COMMAND_OUTPUT=$(eval "${FINAL_COMMAND}" 2>&1)
CLOUD_COMMAND_EXIT_CODE=$?
set -e

INFO "Command exit code: ${CLOUD_COMMAND_EXIT_CODE}"

if [[ ${CLOUD_COMMAND_EXIT_CODE} -ne 0 ]] ; then
  ERROR "Cloud installation creation failed with exit code: ${CLOUD_COMMAND_EXIT_CODE}"
  ERROR "Command output:"
  ERROR "${CLOUD_COMMAND_OUTPUT}"
  ERROR "----"
  ERROR "Environment variables:"
  ERROR "  PROVISIONER_SERVER: ${PROVISIONER_SERVER}"
  ERROR "  INSTALLATION_DNS: ${INSTALLATION_DNS}"
  ERROR "  MM_VERSION: ${MM_VERSION}"
  ERROR "  INSTALLATION_SIZE: ${INSTALLATION_SIZE}"
  ERROR "  INSTALLATION_OWNER: ${INSTALLATION_OWNER}"
  exit ${CLOUD_COMMAND_EXIT_CODE}
fi

INFO "Command completed successfully. Output:"
INFO "${CLOUD_COMMAND_OUTPUT}"

INFO "Parsing installation details from output..."
INSTALLATION_ID=$(echo "${CLOUD_COMMAND_OUTPUT}" | jq --raw-output .ID 2>&1)
JQ_ID_EXIT_CODE=$?
if [[ ${JQ_ID_EXIT_CODE} -ne 0 ]] ; then
  ERROR "Failed to parse installation ID from output using jq"
  ERROR "jq exit code: ${JQ_ID_EXIT_CODE}"
  ERROR "jq output: ${INSTALLATION_ID}"
  ERROR "Raw output was: ${CLOUD_COMMAND_OUTPUT}"
  exit 1
fi

INSTALLATION_STATE=$(echo "${CLOUD_COMMAND_OUTPUT}" | jq --raw-output .State 2>&1)
JQ_STATE_EXIT_CODE=$?
if [[ ${JQ_STATE_EXIT_CODE} -ne 0 ]] ; then
  ERROR "Failed to parse installation state from output using jq"
  ERROR "jq exit code: ${JQ_STATE_EXIT_CODE}"
  ERROR "jq output: ${INSTALLATION_STATE}"
  ERROR "Raw output was: ${CLOUD_COMMAND_OUTPUT}"
  exit 1
fi

INFO "Cloud installation ${INSTALLATION_ID} requested with state: ${INSTALLATION_STATE}"

INFO "Generating Outputs"
echo "id=${INSTALLATION_ID}" >> ${GITHUB_OUTPUT}
echo "state=${INSTALLATION_STATE}" >> ${GITHUB_OUTPUT}

OK "All Done"