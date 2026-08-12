# Project-wide options and core CMake configuration.

if(APPLE)
    enable_language(OBJCXX)
endif()

include(CTest)
include(FetchContent)
set(FETCHCONTENT_BASE_DIR ${CMAKE_BINARY_DIR}/_deps_fc)
find_package(Python3 COMPONENTS Interpreter REQUIRED)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Internal test seams are intentionally OFF by default so release/shared binaries
# do not expose synthetic input injection entry points.
option(
    WXBGI_ENABLE_TEST_SEAMS
    "Enable internal test seam APIs for automated testing (never enable for public release artifacts)."
    OFF
)
option(
    WXBGI_ENABLE_OPENLB
    "Stage optional OpenLB bridge helpers and live-loop demo assets."
    OFF
)
set(OPENLB_ROOT "" CACHE PATH "Path to a local OpenLB release tree (used only when WXBGI_ENABLE_OPENLB=ON)")

# Use static MSVC runtime on Windows (/MT or /MTd) so the binary
# has no dependency on the MSVC Redistributable.
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# ---------------------------------------------------------------------------
# GLFW — FetchContent build or system install
#
# WXBGI_SYSTEM_GLFW=ON: use find_package(glfw3) instead of building from
# source. Required on macOS CI where GLFW 3.4 fails to compile with
# Xcode 16 (Apple Clang 16 rejects implicit CF type casts in .m files even
# with -Wno-incompatible-pointer-types). Install via: brew install glfw
# ---------------------------------------------------------------------------
option(WXBGI_SYSTEM_GLFW
    "Use system-installed GLFW (find_package) instead of FetchContent. \
Enable for CI on macOS to avoid Xcode 16 build errors with GLFW 3.4."
    OFF)

# Make wxWidgets the default window backend.
option(WXBGI_ENABLE_WX
    "Build with wxWidgets window backend (default: ON; fetches wxWidgets 3.2.5)"
    ON)

# GLFW standalone backend (auto-enabled when WX is OFF).
option(WXBGI_ENABLE_GLFW
    "Build with GLFW standalone window backend (default: ON when WXBGI_ENABLE_WX is OFF)"
    OFF)
if(NOT WXBGI_ENABLE_WX)
    set(WXBGI_ENABLE_GLFW ON CACHE BOOL "GLFW fallback" FORCE)
endif()

if(WXBGI_ENABLE_OPENLB)
    if(NOT WXBGI_ENABLE_WX)
        message(FATAL_ERROR "WXBGI_ENABLE_OPENLB requires WXBGI_ENABLE_WX=ON.")
    endif()
    if(OPENLB_ROOT STREQUAL "")
        message(FATAL_ERROR "WXBGI_ENABLE_OPENLB=ON requires OPENLB_ROOT to point at an OpenLB release tree.")
    endif()
    if(NOT EXISTS "${OPENLB_ROOT}/src/olb.h")
        message(FATAL_ERROR "OPENLB_ROOT does not appear to be an OpenLB release tree: expected ${OPENLB_ROOT}/src/olb.h")
    endif()
    message(STATUS "Using OpenLB root: ${OPENLB_ROOT}")
endif()
