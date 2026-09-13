# Focused native warning regressions

These opt-in checks use an already built Qt6 tree. Run on OpenIndiana amd64:

```sh
cmake -S tests -B build/warning-tests \
    -DCMAKE_CXX_COMPILER=/usr/gcc/14/bin/g++ -DCMAKE_CXX_FLAGS=-m64 \
    -DQT_SOURCE="$PWD/qt-everywhere-src-6.11.2" \
    -DQT_BUILD="$PWD/build/amd64" \
    -DCMAKE_PREFIX_PATH="$PWD/build/amd64/qtbase/lib/amd64/cmake"
cmake --build build/warning-tests --parallel 2
QML_IMPORT_PATH="$PWD/build/amd64/qtbase/qml/amd64" \
    ctest --test-dir build/warning-tests --output-on-failure --parallel 2
```

The Collada checks exercise both bundled parsers (including semantic names,
input sets and width-safe offsets) and import a triangle with distinct index
offsets. The Qt check performs a real trash operation in a temporary directory,
checks live property-map bindings, calls the actual Qt3D shader property reader,
imports QtDataVisualization with the offscreen platform plugin, and compiles
the three bundled designer default components without rendering a window.

These are focused regressions, not the full upstream Qt test suite or a desktop
or SPARC certification. The recipe's normal test target remains disabled.
