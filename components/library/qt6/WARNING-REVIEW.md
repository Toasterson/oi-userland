# Qt 6.11.2 warning review

Review of [oi-userland PR #27386](https://github.com/OpenIndiana/oi-userland/pull/27386),
head `e54c6f0ce96856ff135f5a3a3a05e4f860e9547b`, on 2026-09-12.
This branch carries that change on current oi/hipster, with its author and
cherry-pick provenance preserved. This document records proposals, not applied
warning fixes or an upstream merge approval.

## Build evidence

The fresh native amd64 build uses source commit
`72ca36c93377b18052ca296d5809bf9c8e9ba3ff`, GCC 14.3.0, CMake 4.4.3 and Ninja
1.13.2. All declared package dependencies passed `gmake env-check`.
The build uses `PARALLEL_JOBS=2`, and `PFEXEC=/usr/bin/false` prevents automatic
changes to the build host's installed packages. Installation stages a prototype;
publication targets the worktree's private IPS repository.

Configuration has completed and reproduced the policy, bundled CMake and skipped
module warnings described below. Native compilation has also reproduced the
`AT_FDCWD` signedness warning and continued past it. Compilation is in progress;
packaging and runtime validation are not yet established by this fresh build.

Earlier [Jenkins build 2](https://jenkins.openindiana.aurora-opencloud.org/job/OpenIndiana%20Organisation/job/oi-userland/job/PR-27386/2/console)
built and packaged Qt 6.11.2 successfully on 2026-08-22. Its warning counts are
listed below. The latest [build 22](https://jenkins.openindiana.aurora-opencloud.org/job/OpenIndiana%20Organisation/job/oi-userland/job/PR-27386/22/console)
reported success but built TimescaleDB, not Qt6; it is not fresh Qt validation.

## Decisions before integration

1. Change the shared `QT6_VERSION` in `make-rules/shared-macros.mk` from `6.10`
   to `6.11`. The component already installs to the latter path, while consumers
   still discover and encode runtime paths to the former.
2. Coordinate rebuilds and smoke tests for Wireshark, VirtualBox, LibreOffice,
   SQLiteBrowser, qBittorrent, gnuplot and Poppler. Meson also declares Qt6 as a
   test dependency. Confirm the actual reverse-dependency set in IPS before
   releasing the transition. A successful Qt package build alone does not prove
   that existing consumer binaries can find the new versioned directory.
3. Agree an explicit Qt6 maintainer and backup, with responsibility for Solaris
   patches, bundled dependencies, supported modules and consumer rebuilds.
4. Finish the native package build and review its complete diagnostics. Keep
   SPARC and installed desktop runtime testing separate from amd64 build evidence.

## Compiler and linker warnings

Jenkins build 2 emitted 68 compiler/linker warnings:

| Count | Diagnostic | Proposed treatment |
| ---: | --- | --- |
| 42 | Assimp FBX `-Wdangling-reference` | The temporary is the lookup string; the returned `Element` belongs to the `Scope`. Source review agrees with [Assimp's false-positive assessment](https://github.com/assimp/assimp/issues/5145#issuecomment-1599436595). Track an upstream-supported annotation/fix, or constrain any suppression to the affected bundled FBX sources. Do not disable this warning across Qt. |
| 15 | Linker: attempted multiple inclusion of a library | Inspect generated link lines and remove redundant direct/transitive entries where practical. A repeated reference to the same shared library is not evidence of an ABI conflict. Verify dependencies and loader resolution; do not blanket-suppress linker warnings. |
| 5 | Deprecated Qt APIs | Follow up upstream on the specific call sites in Qt3D, QStringBuilder callers and QtQuickEffectMaker. These alone need not block the update. |
| 3 | Assimp Collada `-Wstrict-aliasing` | One has a known upstream correctness fix; backport it as described below. The other two enum-reference casts require a focused parser fix and texture-binding regression fixture. |
| 2 | `-Wno-reorder` passed to a C compiler | Apply the C++-only option using a CMake compile-language condition in the bundled Assimp build configuration. |
| 1 | Qt filesystem `-Wsign-compare` | `parentfd == AT_FDCWD` compares an int with illumos's unsigned `0xffd19553` macro. Use an explicit descriptor-type conversion, then test a real move-to-trash operation. This comparison also exists in Qt 6.10.3. |

### Collada offset correctness

`ReadInputChannel` writes through an `unsigned int &` cast into `channel.mOffset`,
whose actual type is `size_t`. On 64-bit big-endian systems this writes the high
word and corrupts the offset. Backport upstream
[Assimp commit 16c50d7](https://github.com/assimp/assimp/commit/16c50d7b53b5b6536599135004fb003c5e6f88b8)
to both bundled copies, in QtQuick3D and Qt3D: read into an actual unsigned int,
then assign to the size_t. Check a Collada import fixture on amd64 and on SPARC;
the upstream POWER8 test is useful evidence but is not our SPARC test.

The other casts are in `ReadMaterialVertexInputBinding`, where an enum is passed
as an unsigned-int reference while reading `input_semantic`. Fix the semantic
parsing with an appropriate texture-coordinate binding fixture rather than merely
adding another cast. These three source patterns are also present in Qt 6.10.3's
bundled Assimp; they are inherited issues, not newly introduced by this PR.

## Packaging warnings

Jenkins build 2 also emitted:

- **398 `userland.action001.3` warnings** labelling `/usr/clang/21/lib` a 32-bit
  runpath. Native `file` and `elfdump -e` confirm that the installed libclang and
  libLLVM there are ELF64. The lint rule currently recognises directory patterns
  such as `amd64`, `sparcv9` and `64`, but not this Clang layout. Propose a focused
  lint fix with positive and negative cases, while retaining checks for genuine
  32/64-bit path mismatches. Do not replace a correct path with a nonexistent
  `/amd64` suffix or disable the warning on the entire Qt manifest.
- **48 `pkglint.action005.1` warnings** saying that obsolete-dependency checking
  was skipped because the reference manifests were unavailable. Populate/use a
  current canonical lint reference catalog, then rerun lint. This is incomplete
  validation, not proof that the package dependencies are obsolete or missing
  from the installed build environment. It does not justify deleting dependencies.

## Configuration warnings

- **QTP0004, QtDataVisualization:** setting the policy to NEW changes generated
  `qmldir` files and implicit imports. Apply a module-local upstream fix with a
  QML import/designer smoke test, and account for any changed manifest entries.
  [Qt's policy documentation](https://doc.qt.io/qt-6/qt-cmake-policy-qtp0004.html)
  describes the behavior change. Do not silence all CMake author warnings.
- **Bundled Gumbo CMake compatibility:** update its declared minimum/policy
  compatibility only to a version tested by upstream; keep this as a follow-up.
- **QtWebEngine/QtPdf:** platform/compiler checks reject this build. Installing
  the missing Python module, SBOM helper, OpenJPEG, libudev or OpenH264 alone
  will not add illumos support. State which modules are supported and explicitly
  skip unsupported ones where that preserves the intended package contents.
- **QtWebView:** its optional WebEngine dependencies are unavailable, but the
  current manifest ships WebView headers and a QML plugin. The fresh native
  configuration reports every WebView backend disabled. Document that limitation
  and test consumers before promising support or dropping these APIs to quiet warnings.
- **QtOpenAPI:** the new module is skipped for missing dependencies and its CLI
  generator is unavailable. Decide whether to support it or explicitly exclude
  it, then check generated manifests. Avoid environment-dependent module delivery.

The recommended approach is to fix the versioned-path integration issue and the
small proven data-corruption bug, give every remaining warning class an owner and
testable follow-up, and retain the full build logs. A zero-warning build achieved
by broad suppression is not the acceptance criterion.
