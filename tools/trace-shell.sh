#!/usr/bin/bash
# Internal helper used by tools/trace-make.sh as the recipe shell for make.
# It ensures that bash xtrace output goes to a dedicated file descriptor that
# is not affected by per-recipe stdout/stderr redirections.

set -euo pipefail

LOG_PATH=${TRACE_LOG:-trace.log}
# Ensure directory exists (avoid external dirname)
LOG_DIR=${LOG_PATH%/*}
if [ "$LOG_DIR" != "$LOG_PATH" ]; then
  /usr/bin/mkdir -p -- "$LOG_DIR"
fi

# Open FD 9 for appending to the trace log and direct bash xtrace there.
# This prevents recipe-level redirections (e.g., ">file 2>&1") from capturing
# the xtrace stream; it always goes to this file.
exec 9>>"$LOG_PATH"
export BASH_XTRACEFD=9

# Default PS4 if not already set by the environment
: "${PS4:=TRACE: }"
export PS4

# Chain to real bash with whatever flags and command make provides via .SHELLFLAGS
exec /bin/bash "$@"
