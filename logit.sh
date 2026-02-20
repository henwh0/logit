#!/bin/bash

HOST=$(hostname)
PID=$$
DEFAULT_PROGRAM_NAME=$(basename "$0")

logit() {
  local PROGRAM_NAME
  local MESSAGE

  if [[ $# -eq 1 ]]; then
    PROGRAM_NAME=$DEFAULT_PROGRAM_NAME
    MESSAGE="$1"
  else
    PROGRAM_NAME=$1
    shift
    MESSAGE=$2
  fi

  local TIMESTAMP=$(date +"%Y/%m/%d %H:%M:%S")

  printf '%b\n' "${TIMESTAMP} - ${HOST} - ${PROGRAM_NAME}[${PID}]: ${MESSAGE}"
}
