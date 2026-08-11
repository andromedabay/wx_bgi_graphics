message(STATUS "Fetching GLEW...")

FetchContent_Declare(
   glew
   URL https://github.com/nigels-com/glew/releases/download/glew-2.2.0/glew-2.2.0.tgz
   DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(glew)

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

if(WXBGI_SYSTEM_GLFW)
    message(STATUS "Using system GLFW (WXBGI_SYSTEM_GLFW=ON)")
    find_package(glfw3 REQUIRED)
    # glfw3 CMake config exports an imported target named "glfw" — the same
    # name used in target_link_libraries throughout this file.
else()
    message(STATUS "Fetching GLFW...")

    set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
    set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)

    FetchContent_Declare(
       glfw
        URL https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    )
    FetchContent_MakeAvailable(glfw)

    # Apple Clang 16 (Xcode 16.x) tightened C conformance in Objective-C
    # translation units (.m files) and now treats implicit void*→typed-pointer
    # conversions as hard errors. GLFW 3.4's cocoa_monitor.m has several such
    # casts that predate this stricter enforcement. Suppress for glfw only.
    if(APPLE)
        target_compile_options(glfw PRIVATE -Wno-incompatible-pointer-types)
    endif()

    set_target_properties(glfw PROPERTIES POSITION_INDEPENDENT_CODE ON)
endif()

message(STATUS "Fetching GLM...")

set(GLM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLM_ENABLE_CXX_20 ON CACHE BOOL "" FORCE)
FetchContent_Declare(
    glm
    URL https://github.com/g-truc/glm/archive/refs/tags/1.0.1.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(glm)

find_package(OpenGL REQUIRED)

message(STATUS "Fetching nlohmann/json...")

set(JSON_BuildTests OFF CACHE BOOL "" FORCE)
set(JSON_Install    OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
    nlohmann_json
    URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(nlohmann_json)

message(STATUS "Fetching yaml-cpp...")

# yaml-cpp 0.8.0 uses cmake_minimum_required(VERSION 2.8.12) which CMake 4.0+
# rejects unless this policy variable is set.
set(CMAKE_POLICY_VERSION_MINIMUM "3.5" CACHE INTERNAL "")

set(YAML_CPP_BUILD_TESTS   OFF CACHE BOOL "" FORCE)
set(YAML_CPP_BUILD_TOOLS   OFF CACHE BOOL "" FORCE)
set(YAML_CPP_BUILD_CONTRIB OFF CACHE BOOL "" FORCE)
set(YAML_CPP_INSTALL       OFF CACHE BOOL "" FORCE)
set(CUSTOM_SOURCE_DIR_YAML_CPP ${FETCHCONTENT_BASE_DIR}/yaml-cpp-src CACHE INTERNAL "")
FetchContent_Declare(
    yaml-cpp
    URL https://github.com/jbeder/yaml-cpp/releases/download/yaml-cpp-0.9.0/yaml-cpp-yaml-cpp-0.9.0.tar.gz
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    # # Patch_command runs a sed script to replace $$CMAKE_SOURCE_DIR with $$PROJECT_SOURCE_DIR in
    # #    the yaml-cpp CMakeLists.txt file.
    # PATCH_COMMAND
    #     ${CMAKE_COMMAND} -E echo "Patching yaml-cpp CMakeLists.txt to replace {CMAKE_SOURCE_DIR} with ${CUSTOM_SOURCE_DIR_YAML_CPP}"
    #     COMMAND ${CMAKE_COMMAND} -E env sed -i "s|PROJECT_SOURCE_DIR|CUSTOM_SOURCE_DIR_YAML_CPP|g" ${CUSTOM_SOURCE_DIR_YAML_CPP}/CMakeLists.txt
    #     COMMAND ${CMAKE_COMMAND} -E echo "Modified CMakeLists.txt:"
    #     COMMAND ${CMAKE_COMMAND} -E cat ${CUSTOM_SOURCE_DIR_YAML_CPP}/CMakeLists.txt
)
FetchContent_MakeAvailable(yaml-cpp)

message(STATUS "Fetching Manifold...")

set(MANIFOLD_CROSS_SECTION ON CACHE BOOL "" FORCE)
set(MANIFOLD_TEST OFF CACHE BOOL "" FORCE)
set(MANIFOLD_PYBIND OFF CACHE BOOL "" FORCE)
set(MANIFOLD_CBIND OFF CACHE BOOL "" FORCE)
set(MANIFOLD_JSBIND OFF CACHE BOOL "" FORCE)
set(MANIFOLD_PAR OFF CACHE BOOL "" FORCE)
set(MANIFOLD_DOWNLOADS ON CACHE BOOL "" FORCE)
set(MANIFOLD_STRICT OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
FetchContent_Declare(
    manifold
    GIT_REPOSITORY https://github.com/elalish/manifold.git
    GIT_TAG        v3.4.1
    GIT_SHALLOW    ON
)
FetchContent_MakeAvailable(manifold)

message(STATUS "Fetching stb...")

FetchContent_Declare(
    stb
    GIT_REPOSITORY https://github.com/nothings/stb.git
    GIT_TAG        master
    GIT_SHALLOW    ON
)
FetchContent_MakeAvailable(stb)

# Create include prefix "stb/"
set(STB_INCLUDE_DIR ${FETCHCONTENT_BASE_DIR}/include_external/stb)
file(MAKE_DIRECTORY ${STB_INCLUDE_DIR})
# Copy the entire stb directory recursively
file(COPY ${stb_SOURCE_DIR}/ DESTINATION ${STB_INCLUDE_DIR})

# ---------------------------------------------------------------------------
# wxWidgets — unified interface target `wx_bgi_wx_iface`
#
# Two strategies, selected by WXBGI_SYSTEM_WX:
#
#   OFF (default) — FetchContent builds wxWidgets 3.2.5 from source.
#                   Best for self-contained local/Windows builds.
#   ON            — find_package(wxWidgets) uses the system install.
#                   Required on CI for Linux (libwxgtk3.2-dev) and
#                   macOS (brew install wxwidgets) to avoid the 15-min
#                   source build and the bundled-libpng fp.h error.
# ---------------------------------------------------------------------------
if(WXBGI_ENABLE_WX)
    option(WXBGI_SYSTEM_WX
        "Use system-installed wxWidgets (find_package) instead of building from source. \
Enable on Linux/macOS CI after installing libwxgtk3.2-dev / brew wxwidgets."
        OFF)

    # Unified INTERFACE target — rest of the build always links wx_bgi_wx_iface.
    add_library(wx_bgi_wx_iface INTERFACE)

    if(WXBGI_SYSTEM_WX)
        message(STATUS "Using system wxWidgets (find_package)...")
        find_package(wxWidgets 3.0 REQUIRED COMPONENTS core gl base)

        # Propagate all flags through the interface target without using the
        # legacy wxWidgets_USE_FILE (which pollutes directory-level settings).
        target_link_libraries(wx_bgi_wx_iface INTERFACE ${wxWidgets_LIBRARIES})
        target_include_directories(wx_bgi_wx_iface INTERFACE ${wxWidgets_INCLUDE_DIRS})
        if(wxWidgets_CXX_FLAGS)
            separate_arguments(_wx_cxx_flags UNIX_COMMAND "${wxWidgets_CXX_FLAGS}")
            target_compile_options(wx_bgi_wx_iface INTERFACE ${_wx_cxx_flags})
        endif()
        if(wxWidgets_DEFINITIONS)
            target_compile_definitions(wx_bgi_wx_iface INTERFACE ${wxWidgets_DEFINITIONS})
        endif()
    else()
        message(STATUS "Fetching wxWidgets 3.2.5...")
        set(wxBUILD_SHARED  OFF CACHE BOOL "" FORCE)
        set(wxBUILD_TESTS   OFF CACHE STRING "" FORCE)
        set(wxBUILD_SAMPLES OFF CACHE STRING "" FORCE)
        set(wxBUILD_DEMOS   OFF CACHE STRING "" FORCE)

        if(APPLE)
            # wxWidgets 3.2.x bundles libpng which includes <fp.h>. That header was
            # removed from macOS SDKs in Xcode 15+ (macOS Sonoma/Sequoia). Use the
            # macOS system libpng to avoid the build error.
            set(wxUSE_LIBPNG sys CACHE STRING "" FORCE)
        endif()

        FetchContent_Declare(
            wxWidgets
            GIT_REPOSITORY https://github.com/wxWidgets/wxWidgets.git
            GIT_TAG        v3.2.5
            GIT_SHALLOW    OFF
        )
        FetchContent_MakeAvailable(wxWidgets)
        target_link_libraries(wx_bgi_wx_iface INTERFACE wxcore wxgl wxbase)

        # After FetchContent_MakeAvailable(wxWidgets)

        # Choose a predictable staging directory
        set(WX_INSTALL_DIR ${CMAKE_BINARY_DIR}/_wx_install)

        # Ensure the directory exists
        file(MAKE_DIRECTORY ${WX_INSTALL_DIR})

        include_directories(${CMAKE_BINARY_DIR}/_deps_fc/glew-src/include)

        # # Add a custom target that performs the wxWidgets install step
        # add_custom_target(wxwidgets_install ALL
        #     #DEPENDS wxcore wxbase wxgl
        #     COMMAND ${CMAKE_COMMAND}
        #         -DCMAKE_CURRENT_SOURCE_DIR=${FETCHCONTENT_BASE_DIR}/wxwidgets-src
        #         -S${wxwidgets_SOURCE_DIR}
        #         -DCMAKE_CURRENT_BINARY_DIR=${wxwidgets_BINARY_DIR}
        #         -B${wxwidgets_BINARY_DIR}
        #         -DwxBUILD_SHARED=OFF
        #         -DwxBUILD_TESTS=OFF
        #         -DwxBUILD_SAMPLES=OFF
        #         -DwxBUILD_DEMOS=OFF
        #         -DwxBUILD_STATIC=ON
        #         -DwxUSE_BASE=ON
        #         -DwxUSE_BASE=ON
        #         -DwxUSE_GUI=ON
        #         -DwxUSE_UNICODE=ON
        #         -DwxBUILD_INSTALL=ON
        #         -DwxBUILD_INSTALL_PREFIX=${WX_INSTALL_DIR}
        #         # --install ${wxWidgets_BINARY_DIR}
        #     COMMENT "Installing wxWidgets into ${WX_INSTALL_DIR}"
        # )

        ## Start---
        # Choose a predictable staging directory
        set(WX_INSTALL_DIR ${CMAKE_BINARY_DIR}/_wx_install)
        file(MAKE_DIRECTORY ${WX_INSTALL_DIR})

        # Custom target that just runs the install step on the existing wxWidgets build
        add_custom_target(wxwidgets_install
            COMMAND ${CMAKE_COMMAND}
                --install ${wxWidgets_BINARY_DIR}
                --prefix ${WX_INSTALL_DIR}
            COMMENT "Installing wxWidgets into ${WX_INSTALL_DIR}"
        )

        # Make sure wxWidgets is actually built before we try to install it
        add_dependencies(wxwidgets_install wxcore wxgl wxbase)
        ## End---

        # Make your interface target depend on the install step
        add_dependencies(wx_bgi_wx_iface wxwidgets_install)

        # Export the include directory so your packaging step can use it
        target_include_directories(wx_bgi_wx_iface INTERFACE
            ${WX_INSTALL_DIR}/include
        )

    endif()
endif()
