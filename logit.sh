#!/bin/bash

HOST=$(hostname -s)
PID=$$
DEFAULT_PROGRAM_NAME=$(basename "$0")
LOG_FILE="${LOG_FILE:-/var/log/${DEFAULT_PROGRAM_NAME}.log}"

# Validate log file is writable at startup
if [[ ! -w "$(dirname "$LOG_FILE")" && ! -w "$LOG_FILE" ]]; then
    echo "WARNING: Log file $LOG_FILE is not writable" >&2
fi

logit() {
    local level="INFO"
    local program_name="$DEFAULT_PROGRAM_NAME"
    local message

    # Parse optional flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--level)
                level="${2^^}"  # uppercase
                shift 2
                ;;
            -p|--program)
                program_name="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "logit: unknown option: $1" >&2
                return 1
                ;;
            *)
                break
                ;;
        esac
    done

    if [[ $# -eq 0 ]]; then
        echo "Usage: logit [-l LEVEL] [-p program_name] message" >&2
        return 1
    fi

    message="$*"

    local timestamp
    timestamp=$(date +"%Y-%m-%dT%H:%M:%S%z")  # ISO 8601 with timezone

    local line="${timestamp} ${HOST} ${program_name}[${PID}]: [${level}] ${message}"

    if [[ -n "$LOG_FILE" ]]; then
        echo "$line" | tee -a "$LOG_FILE"
    else
        echo "$line"
    fi
}

# Convenience wrappers
log_info()  { logit -l INFO "$@"; }
log_warn()  { logit -l WARN "$@"; }
log_error() { logit -l ERROR "$@"; }
log_debug() { [[ "${DEBUG:-0}" == "1" ]] && logit -l DEBUG "$@"; }
