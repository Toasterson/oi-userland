# Tracing and summarizing tools invoked by the build

This document explains how to capture a trace of every external tool executed by the build and produce a concise Markdown summary listing the tools and the exact arguments they were invoked with. It covers both:

- Top-level: `gmake publish`
- Components tree: `gmake -C components incorporation`

The approach is opt-in and does not change default build behavior. You run a small wrapper to enable shell xtrace for all recipes and then summarize the resulting log.

## Prerequisites

- illumos: use `gmake` (GNU make). On Linux, `make` is typically GNU make; the wrapper auto-detects.
- `/bin/bash` is available (the tree already uses bash).
- `awk` (any POSIX awk, e.g. illumos `awk`/`nawk` or `gawk`).

## Quick start

1) Capture a traced build log

- For top-level publish:

  TRACE_LOG=logs/publish.xtrace bash tools/trace-make.sh publish

- For incorporation in components:

  TRACE_LOG=logs/incorporation.xtrace bash tools/trace-make.sh -C components incorporation

Notes:
- The wrapper uses a dedicated tracing shell (tools/trace-shell.sh) as the recipe shell. It routes bash xtrace (`set -x`) to a private file descriptor (BASH_XTRACEFD) that writes to `TRACE_LOG`. This makes tracing robust even when recipes redirect their stdout/stderr to per-component log files.
- Every simple command observed by the shell is recorded, even though the build uses `-s` (silent make).
- The log will be large; it records all actual commands executed by recipe shells.

2) Produce a Markdown tool summary from the log

- For the `publish` run:

  awk -f tools/make-trace-summary.awk logs/publish.xtrace > logs/publish-tools.md

- For the `incorporation` run:

  awk -f tools/make-trace-summary.awk logs/incorporation.xtrace > logs/incorporation-tools.md

Each output file is a Markdown document listing each tool (by basename) with the number of invocations and example command lines (including arguments) as captured.

## What gets captured

- All commands executed by bash in make recipes, including pipelines and subshells, are traced via `set -x` (xtrace). Make's `-s` (silent) does not suppress this.
- Command lines in the log are prefixed with `TRACE: ` by default. The summarizer looks for those lines.
- The summarizer:
  - Groups by the first executable name (basename) on each traced line.
  - Filters common shell builtins (e.g., `cd`, `echo`, `export`, etc.).
  - Keeps up to 5 example invocations per tool for readability.

## Examples

Generated summary will look like this (illustrative):

- Tool: pkgsend (24 invocations)
  - pkgsend -s /path/to/repo publish --fmri-in-manifest /path/to/manifest.p5m
  - pkgsend -s /path/to/repo publish --fmri-in-manifest /another/manifest.p5m

- Tool: userland-incorporator (1 invocations)
  - /path/to/tools/userland-incorporator --repository /path/to/repo --version=0.X,Y -p userland -c userland --destdir=/path/to/MACH

- Tool: git (3 invocations)
  - /usr/bin/git rev-list HEAD --count
  - /usr/bin/git rev-parse --show-toplevel

- Tool: bass-o-matic (N invocations)
  - /path/to/tools/bass-o-matic --make publish >.../logs/components.publish.log 2>&1

Your actual output will include many more tools (e.g., compilers, pkg* utilities, sed, awk, python, etc.) with the exact arguments used.

## Tips and customization

- Include PID or timestamps in each traced line by setting `PS4` before invoking the wrapper, for example:

  PS4='TRACE: [${BASHPID}] ' TRACE_LOG=logs/publish.xtrace bash tools/trace-make.sh publish

  The summarizer only requires the line to start with `TRACE:`; extra details are fine.

- To adjust what commands are considered shell builtins (ignored by the summary), edit the `builtins` list near the top of `tools/make-trace-summary.awk`.

- The wrapper passes a custom recipe shell and `.SHELLFLAGS` on the make command line. GNU make propagates these to recursive sub-makes via `MAKEFLAGS`, so tracing remains active throughout the entire build.

- This process executes a real build. If you only need to observe a subset, consider limiting to a single component directory or a specific target.

## Files added by this feature

- tools/trace-make.sh — wrapper to run make with tracing enabled, capturing output to a log.
- tools/trace-shell.sh — recipe shell used to route xtrace to the log via BASH_XTRACEFD.
- tools/make-trace-summary.awk — AWK script that converts an xtrace log into a Markdown summary.

## Troubleshooting

- Empty summary: ensure your log contains lines starting with `TRACE:`. Double-check you invoked make using the wrapper and that `TRACE_LOG` points to a writable location.
- Non-bash shells: the workspace already sets `SHELL=/bin/bash` in `make-rules/shared-macros.mk`. The wrapper uses bash explicitly and enables xtrace.
- Path differences (illumos vs Linux): the wrapper prefers `gmake` if available, otherwise `make`.
