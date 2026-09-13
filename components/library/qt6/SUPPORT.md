# OpenIndiana Qt 6.11 module and release checklist

The recipe explicitly skips QtGrpc, QtWebEngine (including QtPdf) and QtOpenAPI.
QtWebEngine rejects the Solaris platform/compiler combination. Installing its
optional dependencies does not provide an illumos port. QtOpenAPI requires a
separately supported generator and dependency setup before it can be enabled.
Enabling either needs its own build, manifest and runtime review.

QtWebView headers, libraries and the QML plugin remain packaged for compatibility.
All native web-view backends are disabled on this platform. Importing the API
does not establish working web content rendering. Consumers requiring a WebView
backend are unsupported until a backend is ported and tested. Do not remove the
API, or claim browser support, merely to eliminate a configure warning.

Before publishing the 6.10 to 6.11 directory transition:

- Agree a primary Qt6 maintainer and backup; neither role is assigned by this patch.
- Rebuild Wireshark, VirtualBox, LibreOffice, SQLiteBrowser, qBittorrent, gnuplot
  and Poppler against the new shared Qt6 paths. Their revision bumps schedule the
  required rebuilds; they do not certify those builds or applications.
- Exercise Meson's Qt6 dependency tests separately (it is a test consumer).
- Inspect the resulting Qt consumers for old 6.10 RUNPATHs, resolve libraries,
  and smoke-test the desktop applications before a coordinated release.
- Validate QML DataVisualization imports and designer resources, asset import,
  native trash operations, and QDoc with the packaged libraries.
- Run the reference-catalog lint procedure in `tools/README.pkglint.md`.
- Obtain SPARC build/runtime evidence before making SPARC support claims.

The maintainer and backup should review bundled dependency updates, Solaris
patches, supported modules and the reverse-dependency rebuild set at each update.
Keep native build/package evidence separate from installed application results.
