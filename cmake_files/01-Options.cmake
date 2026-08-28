# Project-wide options and core CMake configuration.

if(WXBGI_ENABLE_CLEAN_TARGET)
    return()
endif()

if(APPLE)
    enable_language(OBJCXX)
endif()

include(CTest)
include(FetchContent)
set(FETCHCONTENT_BASE_DIR ${CMAKE_BINARY_DIR}/_deps_fc)
find_package(Python3 COMPONENTS Interpreter REQUIRED)
find_package(OpenGL REQUIRED)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(WXBGI_BUILD_SHARED
    "Build phoenix_gi as a shared library (default: ON)."
    ON
)

option(WXBGI_INSTALL_HEADERS
    "Install the public headers alongside the library output."
    ON
)

option(WXBGI_INSTALL_DOCS
    "Install generated Doxygen documentation alongside the library output."
    ON
)

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
option(
    WXBGI_ENABLE_CLEAN_TARGET
    "Add an opt-in clean target that removes build* directories and third_party/installed contents except .gitignore."
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

set(GIT_URL_GLEW "https://github.com/nigels-com/glew.git")
set(GIT_TAG_GLEW "glew-2.3.1")
set(GIT_URL_GLFW "https://github.com/glfw/glfw.git")
set(GIT_TAG_GLFW "3.5.1")
set(GIT_URL_GLM "https://github.com/g-truc/glm.git")
set(GIT_TAG_GLM "1.0.3")
set(GIT_URL_NLOHMANN_JSON "https://github.com/nlohmann/json.git")
set(GIT_TAG_NLOHMANN_JSON "v3.12.0")
set(GIT_URL_YAML_CPP "https://github.com/jbeder/yaml-cpp.git")
set(GIT_TAG_YAML_CPP "yaml-cpp-0.9.0")
set(GIT_URL_MANIFOLD "https://github.com/elalish/manifold.git")
set(GIT_TAG_MANIFOLD "v3.5.2")
set(GIT_URL_STB "https://github.com/nothings/stb.git")
set(GIT_TAG_STB "master")
set(GIT_URL_WXWIDGETS "https://github.com/wxWidgets/wxWidgets.git")
set(GIT_TAG_WXWIDGETS "v3.3.3")
