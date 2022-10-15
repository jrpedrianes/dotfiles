#!/bin/zsh

#
# Copyright (c) 2021-present KuFlow S.L.
#
# All rights reserved.
#

function __dcfp_get_config_dir {
  echo "${HOME}/.config/docker-compose-forward-ports"
}

function __dcfp_get_config_file {
  echo "$(__dcfp_get_config_dir)/config.json"
}

function __dcfp_get_docker_compose_ports {
  cat "${1}" | yq '.services[].ports' | grep "-" | tr -d "'- '" | sed 's/:.*//'
}

function __dcfp_get_ssh_control_file {
  echo "/tmp/ssh-$(echo "$1" | md5)"
}

function __dcfp_start {
  local docker_compose_file
  local destination
  local port
  local ports
  local ssh_arguments
  local ssh_control_file
  local config_content
  local status_json
  local ssh_cmd

  docker_compose_file=$1
  destination=$2

  if [[ "${docker_compose_file}" == "" || "${destination}" == "" ]]; then
    echo ""
    echo "Docker compose file or destination is required ❗️"
    echo ""
    echo "  $> docker-compose-forward-ports start ./docker-compose.yml user@192.166.1.10"
    echo ""
    return 1
  fi

  docker_compose_file=$(realpath "${docker_compose_file}")

  if [[ ! -f "${docker_compose_file}" ]]; then
    echo ""
    echo "Docker compose file ${docker_compose_file} doesn't exists ❗️"
    echo ""
    return 1
  fi

  ssh_control_file=$(__dcfp_get_ssh_control_file "${docker_compose_file}")

  if [[ -S "${ssh_control_file}" ]]; then
    echo ""
    echo "Docker compose already forwarded ❗️"
    echo ""
    return 1
  fi

  mkdir -p "$(__dcfp_get_config_dir)"
  if [[ ! -f "$(__dcfp_get_config_file)" ]]; then
    echo '{ "status": [] }' > "$(__dcfp_get_config_file)"
  fi

  config_content=$(cat "$(__dcfp_get_config_file)")

  # Remove previous if exist
  config_content=$(echo "${config_content}" | jq --arg docker_compose_file "${docker_compose_file}" 'del(.status[] | select(.docker_compose_file == $docker_compose_file))')

  # Create new
  status_json=$(jq \
    --null-input \
    --arg docker_compose_file "${docker_compose_file}" \
    --arg destination "${destination}" \
    '{ "docker_compose_file": $docker_compose_file, "destination": $destination }')

  echo "${config_content}" | jq --argjson status "${status_json}" '.status += [$status]' > "$(__dcfp_get_config_file)"

  ports=$(cat "${docker_compose_file}" | yq '.services[].ports' | grep "-" | tr -d "'- '" | sed 's/:.*//')

  ssh_arguments=""
  for port in $(echo ${ports}); do
    ssh_arguments="${ssh_arguments} -L ${port}:localhost:${port}"
  done

  ssh_cmd="ssh -N \
      -f \
      -o ExitOnForwardFailure=yes \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no \
      -o ServerAliveInterval=60 \
      -o ServerAliveCountMax=3 \
      -o LogLevel=ERROR \
      -M \
      -S ${ssh_control_file} ${ssh_arguments} ${destination}"

  $(echo ${ssh_cmd})

  echo ""
  echo " 👍 Connected"
  echo ""
}

function __dcfp_stop {
  local docker_compose_file
  local destination
  local ssh_control_file
  local config_content

  docker_compose_file=$1

  if [[ "${docker_compose_file}" == "" ]]; then
    echo "Docker compose file is required ❗️"
    echo ""
    echo "  $> docker-compose-forward-ports stop ./docker-compose.yml"
    echo ""
    return 1
  fi

  docker_compose_file=$(realpath $1)

  if [[ ! -f "${docker_compose_file}" ]]; then
    echo ""
    echo "Docker compose file ${docker_compose_file} doesn't exists ❗️"
    echo ""
    return 1
  fi

  ssh_control_file=$(__dcfp_get_ssh_control_file "${docker_compose_file}")

  if [[ -S "${ssh_control_file}" ]]; then
    destination=$(cat "$(__dcfp_get_config_file)" | jq -r --arg docker_compose_file "${docker_compose_file}" '.status[] | select(.docker_compose_file == $docker_compose_file) | .destination')

    ssh -S "${ssh_control_file}" -O exit "${destination}"
  fi

  # Remove config
  config_content=$(cat "$(__dcfp_get_config_file)")
  config_content=$(echo "${config_content}" | jq --arg docker_compose_file "${docker_compose_file}" 'del(.status[] | select(.docker_compose_file == $docker_compose_file))')
  echo "${config_content}" > "$(__dcfp_get_config_file)"

  echo ""
  echo " 👋 Bye"
  echo ""
}

function __dcfp_status {
  local statuses_base64
  local status_base64
  local status_docker_compose_file
  local status_destination
  local ssh_control_file
  local ssh_control_status

  statuses_base64=$(cat "$(__dcfp_get_config_file)" | jq -r -c '.status[] | @base64')

  echo ""
  echo "Active port forwards"
  echo ""
  for status_base64 in $(echo "${statuses_base64}"); do
    status_docker_compose_file=$(echo "${status_base64}" | base64 --decode | jq -r ".docker_compose_file")
    status_destination=$(echo "${status_base64}" | base64 --decode | jq -r ".destination")

    ssh_control_file=$(__dcfp_get_ssh_control_file "${status_docker_compose_file}")
    ssh_control_status=$([[ -S "${ssh_control_file}" ]] && echo ✅ || echo ❌)

    echo "${status_docker_compose_file}  -> ${status_destination} ${ssh_control_status} "
  done
  echo ""
}

function __dcfp_help {
  echo ""
  echo "Usage: "
  echo "  $> docker-compose-forward-ports <command>"
  echo ""
  echo "Command:"
  echo "  start:  Start port forwarding"
  echo "  stop:   Stop port forwarding"
  echo "  status: Status port forwarding"
  echo ""
}

function __dcfp_main {
  local command=$1
  [[ ! -z "${command}" ]] && shift 2> /dev/null

  case "${command}" in
    start)
      __dcfp_start "$@"
      ;;
    stop)
      __dcfp_stop "$@"
      ;;
    status)
      __dcfp_status "$@"
      ;;
    *)
      __dcfp_help
      ;;
  esac
}

function docker-compose-forward-ports {
  setopt localoptions errreturn

  __dcfp_main "$@"
}
