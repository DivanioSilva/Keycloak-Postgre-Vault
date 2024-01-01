##!/usr/bin/env bash
#set -e
#base_dir="$(dirname "$(readlink -f "$0")")"

#main() {
#  cd "$base_dir"
#  local action=$1
#  echo "Action: '$action'"

#  if [ "$action" = "" ]; then
#      build "$@"
#      return
#  fi

#  shift
#  if [ "$action" = "run" ]; then
#    run "$@"
#  elif [ "$action" = "vault" ]; then
#    vault "$@"
#  else
#    echo "ERROR. unknown action $action"
#  fi
#}
VAULT_HEALTH_CHECK_ADDR="http://127.0.0.1:8200/v1/sys/health?perfstandbyok=true"

  echo "Destroying environment..."
  docker-compose -f docker-compose-dev.yml down
  echo "Starting environment..."
  docker-compose -f docker-compose-dev.yml up -d
  echo "Waiting for Vault"
  while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' "${VAULT_HEALTH_CHECK_ADDR}")" != "200" ]]; do sleep 5; done
  echo "Launching the vault scripts on pod"
  docker exec vault /bin/sh -c "source vault.sh"
  echo "Restarting keycloak"
  docker restart keycloak
  echo "System is ready, enjoy! :-)"

