#!/usr/bin/bash
# Trace all shell commands executed by make recipes and capture them to a log.
# This is an opt-in wrapper that does not modify the default build.
#
# Usage examples:
#   tools/trace-make.sh publish
#   tools/trace-make.sh -C components incorporation
#
# You can override the output log path with TRACE_LOG=/path/to/log
#   TRACE_LOG=logs/publish-trace.log tools/trace-make.sh publish
#
# Notes:
# - This wrapper enables bash xtrace for all recipe shells by setting
#   SHELL to tools/trace-shell.sh, which routes xtrace to a dedicated FD
#   (BASH_XTRACEFD), making it robust against recipe-level redirections.
# - Output includes every simple command as seen by the shell, regardless of
#   the top-level Makefile using "-s" (silent).
# - The resulting log can be summarized using tools/make-trace-summary.awk.
set -euo pipefail

# Pick make implementation: prefer gmake if available (illumos), fallback to make
if command -v gmake >/dev/null 2>&1; then
  MAKE_CMD=gmake
else
  MAKE_CMD=make
fi

LOG_PATH=${TRACE_LOG:-trace.log}
# Ensure directory exists if a path with directories is provided (avoid external dirname)
LOG_DIR=${LOG_PATH%/*}
if [ "$LOG_DIR" != "$LOG_PATH" ]; then
  /usr/bin/mkdir -p -- "$LOG_DIR"
fi

# Distinct, easily matchable PS4 prefix for xtrace lines (can be overridden by env)
: "${PS4:=TRACE: }"
export PS4

# Absolute path to the tracing shell wrapper (avoid external dirname/pwd)
_script_path=${BASH_SOURCE[0]:-$0}
case "$_script_path" in
  */*) _script_dir=${_script_path%/*} ;;
  *)   _script_dir=$PWD ;;
esac
# Make absolute if needed
case "$_script_dir" in
  /*) : ;;
  *) _script_dir="$PWD/$_script_dir" ;;
esac
TRACE_SHELL="$_script_dir/trace-shell.sh"

# Export TRACE_LOG so the shell wrapper writes to the correct file
export TRACE_LOG="$LOG_PATH"

# Enable xtrace via .SHELLFLAGS; include -c at the end per make's contract
exec "$MAKE_CMD" "$@" \
  SHELL="$TRACE_SHELL" \
  .SHELLFLAGS='-o pipefail -o xtrace -c'
