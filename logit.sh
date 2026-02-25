#!/bin/bash

HOST=$(hostname)
PID=$$
DEFAULT_PROGRAM_NAME=$(basename "$0")

logit() {
    local PROGRAM_NAME
    local MESSAGE

    if [[ $# -eq 0 ]]; then
        echo "Usage: logit [program_name] message" >&2
        return 1
    fi

    if [[ $# -eq 1 ]]; then
        # Only message provided, use default program name
        PROGRAM_NAME=$DEFAULT_PROGRAM_NAME
        MESSAGE="$1"
    else
        # Program name and message provided
        PROGRAM_NAME=$1
        shift
        MESSAGE="$*"
    fi

    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${TIMESTAMP} ${HOST} ${PROGRAM_NAME}[${PID}]: ${MESSAGE}" | tee -a "$LOG_FILE"
}
