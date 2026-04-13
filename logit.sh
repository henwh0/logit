#!/bin/bash

HOST=$(hostname -s)
PID=$$
DEFAULT_PROGRAM_NAME=$(basename "$0")
LOG_FILE="${LOG_FILE:-/var/log/${DEFAULT_PROGRAM_NAME}.log}"

# Validate log file
if [[ -e "$LOG_FILE" ]]; then
    [[ -w "$LOG_FILE" ]] || echo "WARNING: Log file $LOG_FILE is not writable" >&2
else
    if [[ -w "$(dirname "$LOG_FILE")" ]]; then
        :
    else
        echo "WARNING: Cannot create log file in $(dirname "$LOG_FILE")" >&2
    fi
fi

logit() {
    local level="INFO"
    local program_name="$DEFAULT_PROGRAM_NAME"
    local message
    local exit_code=$?

    # Parse optional flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--level)
                [[ -n "$2" ]] || { echo "logit: missing argument for $1" >&2; return 1; }
                level="${2^^}"  # uppercase
                shift 2
                ;;
            -p|--program)
                [[ -n "$2" ]] || { echo "logit: missing argument for $1" >&2; return 1; }
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
    timestamp=$(date +"%Y-%m-%dT%H:%M:%S%z") 

    local line="${timestamp} ${HOST} ${program_name}[${PID}]: [${level}] ${message}"

    echo "$line"
    [[ -n "$LOG_FILE" ]] && echo "$line" >> "$LOG_FILE" 2>/dev/null
}

# Wrappers
log_info()  { logit -l INFO "$@"; }
log_warn()  { logit -l WARN "$@"; }
log_error() { logit -l ERROR "$@"; }
log_debug() { [[ "${DEBUG:-0}" == "1" ]] && logit -l DEBUG "$@"; }
