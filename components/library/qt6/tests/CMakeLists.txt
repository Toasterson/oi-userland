# SPDX-License-Identifier: CDDL-1.0
cmake_minimum_required(VERSION 3.22)
project(Qt6WarningRegressions LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
enable_testing()
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick 3DCore 3DRender 3DQuickRender 3DRenderPrivate 3DQuickRenderPrivate)
add_executable(qt-warning-regressions qt-warning-regressions.cpp)
target_link_libraries(qt-warning-regressions PRIVATE Qt6::Core Qt6::Gui Qt6::Qml
    Qt6::Quick Qt6::3DQuickRenderPrivate Qt6::3DRenderPrivate)
add_test(NAME qt-warning-regressions COMMAND qt-warning-regressions)
set_tests_properties(qt-warning-regressions PROPERTIES ENVIRONMENT "QT_QPA_PLATFORM=offscreen")

# Test each independently linked bundled Assimp copy. QT_SOURCE and QT_BUILD
# refer to an already prepared source and completed native Qt build.
foreach(module qtquick3d qt3d)
    set(assimp "${QT_SOURCE}/${module}/src/3rdparty/assimp/src")
    if(module STREQUAL "qtquick3d")
        set(plugin "assetimporters/libassimp.so")
    else()
        set(plugin "sceneparsers/libassimpsceneimport.so")
    endif()
    add_executable(collada-${module} collada-regressions.cpp)
    target_include_directories(collada-${module} PRIVATE "${assimp}/include"
        "${assimp}/code" "${assimp}/contrib/pugixml/src")
    target_link_libraries(collada-${module} PRIVATE
        "${QT_BUILD}/qtbase/plugins/amd64/${plugin}")
    add_test(NAME collada-${module} COMMAND collada-${module} "${CMAKE_CURRENT_SOURCE_DIR}/triangle.dae")
endforeach()
