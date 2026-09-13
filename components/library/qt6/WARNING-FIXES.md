# Patches following the Qt 6.11.2 warning review

The baseline findings in [WARNING-REVIEW.md](WARNING-REVIEW.md) now have focused
commits on this fork branch. These changes have not been merged upstream.

| Finding | Patch or action |
| --- | --- |
| Consumer paths still point at 6.10 | Shared `QT6_VERSION` is 6.11; seven runtime consumer recipes have revision bumps for a coordinated rebuild. |
| Collada offset writes through the wrong integer type | [17-assimp-collada-offset.patch](patches/17-assimp-collada-offset.patch) backports Assimp 16c50d7 to both bundled copies. |
| Collada material semantic parsed as an integer | [18-assimp-collada-binding.patch](patches/18-assimp-collada-binding.patch) uses the existing name decoder and removes duplicate parsing. |
| FBX dangling-reference false positives | [19-assimp-fbx-lifetime.patch](patches/19-assimp-fbx-lifetime.patch) feature-tests GCC's annotation on the single Scope lookup function. Other functions retain the diagnostic. |
| Signedness of the trash directory sentinel | [20-trash-dirfd-type.patch](patches/20-trash-dirfd-type.patch) compares the sentinel as the descriptor type accepted by `openat`. |
| C++ warning option passed to C | [21-assimp-cxx-options.patch](patches/21-assimp-cxx-options.patch) restricts `-Wno-reorder` to C++ compilation. |
| Deprecated QStringBuilder pointer concatenation | [22-qmltc-string-literals.patch](patches/22-qmltc-string-literals.patch) preserves QString type across the conditional. |
| Deprecated Qt3D QJSValue probe | [23-qt3d-js-variant.patch](patches/23-qt3d-js-variant.patch) converts native values and arrays while retaining arbitrary JS object identity. |
| Deprecated Effect Maker property-map constructors | [24-effectmaker-property-maps.patch](patches/24-effectmaker-property-maps.patch) uses the supported factory with explicit ownership. |
| Repeated XCB and DRM libraries | [25-xcb-egl-link-order.patch](patches/25-xcb-egl-link-order.patch) lets CMake order and deduplicate direct/transitive dependencies within the two affected Solaris platform directories. Requires CMake 3.31 or newer; older CMake retains its previous behavior. [28-xcb-library-identities.patch](patches/28-xcb-library-identities.patch) also unifies the AUX/UTIL and xkbcommon dependency identities. |
| QTP0004 | [26-datavisualization-qml-policy.patch](patches/26-datavisualization-qml-policy.patch) enables the policy locally; both new designer `qmldir` redirects are included in the manifests. |
| Gumbo CMake compatibility | [27-gumbo-cmake-minimum.patch](patches/27-gumbo-cmake-minimum.patch) adopts upstream's 3.11 minimum. |
| Clang's library path misclassified as 32-bit | The pkglint runpath rule recognizes the exact versioned Clang layout and checks it in both directions; similar paths receive no exemption. |
| Missing lint reference manifests | `CANONICAL_REPO` now passes `-r` as well as `-c`, populating the opt-in private catalog cache. See [lint instructions](../../../tools/README.pkglint.md). |
| Duplicate staging link and absent Python scripts | The duplicate `qdbusviewer` and two uninstalled `PYTHON_SCRIPTS` destinations are removed. |
| Unsupported/variable module delivery and maintenance ownership | WebEngine/Pdf and OpenAPI are explicitly excluded. WebView's API remains packaged with its backend limitation documented. [SUPPORT.md](SUPPORT.md) records the release and ownership work that remains. |

## Validation

The native pkglint regression suite passes all four test methods, covering the
Clang layout, genuine mismatches, similar paths and mixed runpath lists.
The [native Qt regressions](tests/README.md) were first run against the original
libraries: both Collada tests fail on semantic decoding, and the Qt test fails
on numeric shader conversion. This establishes that the tests distinguish the
old behavior. The baseline trash and property-map binding checks passed before
that Qt test reached the shader failure.

A native rebuild is in progress with `PARALLEL_JOBS=2`. All 19 modified source
files match independently applied tracked patches. A first incremental pass was
stopped to add the XCB dependency-identity fix. The subsequent standard recipe
recreated the build directory, so the final pass is a full compilation using the
prepared patched sources. Original package/prototype evidence is preserved.
Fresh prototype staging and private publication follow compilation.

Opt-in reference lint passed with no warnings against the baseline manifest
using a newly populated Hipster catalog (10,626 reference manifests). It will be
rerun against the final resolved manifest, including the two new qmldir files.
Final build, regression, loader and reference-lint results remain pending.

Consumer rebuilds, installed desktop/rendering tests, maintainer/backup agreement
and SPARC results remain release requirements. Revision bumps and support notes
do not certify or assign that work.
