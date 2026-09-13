# Linting with a reference repository

From a component directory, opt into a current OpenIndiana reference catalog:

```sh
gmake PARALLEL_JOBS=2 PFEXEC=/usr/bin/false \
    CANONICAL_REPO=https://pkg.openindiana.org/hipster/ lintme
```

`CANONICAL_REPO` now supplies both `-c` and `-r` to pkglint. A cache by itself
cannot check obsolete dependencies. The default cache is worktree-local
`$(WS_MACH)/pkglint-cache`; use `WS_LINT_CACHE=/absolute/private/cache` for an
isolated run. pkglint manages a catalog image inside that directory. It does
not alter the running system's packages or publishers. Cache initialization
can take time and storage; reuse it for subsequent components.

No network reference is added to builds that omit `CANONICAL_REPO`. Such runs
may report `pkglint.action005.1`; this means reference validation is incomplete,
not that dependencies are obsolete. Do not suppress it or delete dependencies.
Record the URI, lint date, source revision and exit status with release evidence.
Refresh the reference when preparing a release and review any newly exposed
obsolete dependencies. A repository outage is a failed check, not a reason to
silently reuse an unverified result.

Run the runpath regression checks on OpenIndiana from the workspace root:

```sh
PYTHONPATH=tools/python /usr/bin/python -m unittest discover \
    -s tools/python/pkglint/tests
```
