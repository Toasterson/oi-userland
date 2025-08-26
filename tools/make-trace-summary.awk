#!/usr/bin/awk -f
# Convert a bash xtrace log (from tools/trace-make.sh) into a Markdown
# summary of external tool invocations with arguments.
#
# Usage:
#   awk -f tools/make-trace-summary.awk trace.log > tools-summary.md
#
# Assumptions:
# - The log contains lines prefixed by PS4='TRACE: ' (set by the wrapper).
# - Each traced line represents a simple command or a pipeline as executed by bash.
# - We heuristically skip common shell builtins and focus on external tools.

BEGIN {
  prefix = "TRACE: ";
  maxExamples = 5;
  # builtins and no-interest commands to skip
  split("cd echo eval : true false builtin local typeset declare readonly export unalias alias hash read wait trap getopts return set shopt ulimit umask pwd times source . exec printf test [ ]", arr, " ")
  for (i in arr) builtins[arr[i]] = 1
}

function ltrim(s){ sub(/^\s+/, "", s); return s }
function rtrim(s){ sub(/\s+$/, "", s); return s }
function trim(s){ return rtrim(ltrim(s)) }

function strip_prefix(s) {
  sub(/^TRACE:[[:space:]]*/, "", s)
  return s
}

# Extract the primary command name from a traced line. Also returns the
# normalized command token (basename without path) in cmd_base via reference-like global.
function extract_cmd(line,    s,tok,parts,n) {
  s = strip_prefix(line)
  s = trim(s)
  # Drop leading grouping parens/braces
  while (s ~ /^[({]/) { s = substr(s,2); s = trim(s) }
  # Skip variable assignments (VAR=...) at start
  while (s ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
    match(s, /^[^[:space:]]+[[:space:]]*/) ; s = substr(s, RLENGTH+1); s = trim(s)
  }
  # Special case: env VAR=... cmd
  if (s ~ /^env[[:space:]]+/) {
    s = substr(s, 4); s = trim(s)
    while (s ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
      match(s, /^[^[:space:]]+[[:space:]]*/) ; s = substr(s, RLENGTH+1); s = trim(s)
    }
  }
  # Special case: exec cmd -> treat cmd as the tool
  if (s ~ /^exec[[:space:]]+/) { s = substr(s, 5); s = trim(s) }
  # First token until space or control operator
  if (match(s, /^[^|&;<>[:space:]]+/)) {
    tok = substr(s, RSTART, RLENGTH)
  } else {
    tok = s
  }
  # Compute basename
  n = split(tok, parts, "/"); cmd_base = parts[n]
  return tok
}

# Add an example line for the tool if not already recorded, up to maxExamples
function add_example(tool, line,    key) {
  key = tool "\n" line
  if (! (key in seen)) {
    seen[key] = 1
    exCount[tool]++
    if (exCount[tool] <= maxExamples) {
      ex[tool, exCount[tool]] = strip_prefix(line)
    }
  }
}

# Filtering: return 1 if command should be ignored
function is_ignored(cmd_base) {
  return (cmd_base in builtins)
}

# Main processing loop
/^.*/ {
  if (index($0, prefix) == 1) {
    fullcmd = extract_cmd($0)
    base = cmd_base
    if (base == "") next
    if (is_ignored(base)) next
    count[base]++
    add_example(base, $0)
  }
}

END {
  print "# Tool invocation summary";
  print "";
  print "Generated from: " FILENAME;
  print "";
  # Gather keys for deterministic-ish ordering (alphabetical)
  i = 0
  for (k in count) { keys[++i] = k }
  # Simple bubble sort for portability
  for (m = 1; m <= i; m++) {
    for (n = m+1; n <= i; n++) {
      if (keys[m] > keys[n]) { tmp = keys[m]; keys[m] = keys[n]; keys[n] = tmp }
    }
  }
  for (j = 1; j <= i; j++) {
    tool = keys[j]
    print "- Tool: " tool " (" count[tool] " invocations)"
    # Print recorded examples
    for (e = 1; e <= exCount[tool] && e <= maxExamples; e++) {
      print "  - " ex[tool, e]
    }
    print ""
  }
  if (i == 0) {
    print "(No external tool invocations detected. Ensure tracing was enabled and the log contains lines starting with 'TRACE: '.)"
  }
}
