# GET Source and Build Dependency - wxWidgets

set(EP_BASE_WXWIDGETS ${EP_BASE_PREFIX}/wxwidgets)
set(EP_BUILD_WXWIDGETS ${EP_BUILD_PREFIX}/wxwidgets)
set(EP_INSTALL_WXWIDGETS ${EP_INSTALL_PREFIX}/wxwidgets)

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
        message(STATUS "Fetching wxWidgets ${GIT_TAG_WXWIDGETS} ...")
        set(wxBUILD_SHARED  OFF CACHE BOOL "" FORCE)
        set(wxBUILD_TESTS   OFF CACHE STRING "" FORCE)
        set(wxBUILD_SAMPLES OFF CACHE STRING "" FORCE)
        set(wxBUILD_DEMOS   OFF CACHE STRING "" FORCE)
        set(wxBUILD_INSTALL_LOCALE OFF CACHE BOOL "" FORCE)

        if(APPLE)
            # wxWidgets 3.2.x bundles libpng which includes <fp.h>. That header was
            # removed from macOS SDKs in Xcode 15+ (macOS Sonoma/Sequoia). Use the
            # macOS system libpng to avoid the build error.
            set(wxUSE_LIBPNG sys CACHE STRING "" FORCE)
        endif()

        FetchContent_Declare(
            wxWidgets
            # GIT PULL UPSTREAM - WXWIDGETS
            GIT_REPOSITORY ${GIT_URL_WXWIDGETS}
            #GIT_TAG        v3.2.5
            GIT_TAG        ${GIT_TAG_WXWIDGETS}
            GIT_SHALLOW    OFF
            # # DOWNLOAD SOURCE TAR BAR - WXWIDGETS
            # URL https://github.com/wxWidgets/wxWidgets/archive/refs/tags/v3.3.3.tar.gz
            DOWNLOAD_EXTRACT_TIMESTAMP TRUE            
            UPDATE_COMMAND
            ""
            PREFIX ${EP_BUILD_WXWIDGETS}
            SOURCE_DIR ${EP_BASE_WXWIDGETS}
            BINARY_DIR ${EP_INSTALL_WXWIDGETS}                   
        )
        FetchContent_MakeAvailable(wxWidgets)

        # # START - Remove all within-target .git subfolders...
        # execute_process(
        #     COMMAND ${CMAKE_COMMAND} -E remove_directory ${EP_BASE_WXWIDGETS}/.git
        # )
        # # Remove any submodule .git directories
        # execute_process(
        #     COMMAND ${CMAKE_COMMAND} -E remove_directory ${EP_BASE_WXWIDGETS}/.git/modules
        # )
        # # Recursively remove any stray .git folders (submodules, nested repos)
        # file(GLOB_RECURSE GIT_DIRS
        #     "${EP_BASE_WXWIDGETS}/*/.git"
        # )
        # foreach(GITDIR ${GIT_DIRS})
        #     message(STATUS "Removing Git metadata: ${GITDIR}")
        #     execute_process(
        #         COMMAND ${CMAKE_COMMAND} -E remove_directory ${GITDIR}
        #     )
        # endforeach()
        # # END - Remove all within-target .git subfolders

        target_link_libraries(wx_bgi_wx_iface INTERFACE wxcore wxgl wxbase)

        # After FetchContent_MakeAvailable(wxWidgets)

        # Choose a predictable staging directory
        ## set(WX_INSTALL_DIR ${CMAKE_BINARY_DIR}/_wx_install)
        set(WX_INSTALL_DIR ${EP_INSTALL_WXWIDGETS})

        # Ensure the directory exists
        file(MAKE_DIRECTORY ${WX_INSTALL_DIR})

        ## include_directories(${CMAKE_BINARY_DIR}/_deps_fc/glew-src/include)
        #include_directories(${EP_BASE_GLEW}/auto/src)
        include_directories(${glew_SOURCE_DIR}/include)

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
        # set(WX_INSTALL_DIR ${CMAKE_BINARY_DIR}/_wx_install)
        # file(MAKE_DIRECTORY ${WX_INSTALL_DIR})

        # Custom target that just runs the install step on the existing wxWidgets build
        add_custom_target(wxwidgets_install
            COMMAND ${CMAKE_COMMAND}
                --install ${wxWidgets_BINARY_DIR}
                --prefix ${WX_INSTALL_DIR}
            COMMENT "Installing wxWidgets into ${WX_INSTALL_DIR}"
        )

        # Make sure wxWidgets is actually built before we try to install it
        ##add_dependencies(wxwidgets_install wxcore wxgl wxbase)

        add_dependencies(wxwidgets_install
            wxbase
            wxcore
            wxnet
            wxxml
            wxhtml
            wxgl
            wxpropgrid
            wxrichtext
        )

        ## End---

        # Make your interface target depend on the install step
        add_dependencies(wx_bgi_wx_iface wxwidgets_install)

        # Export the include directory so your packaging step can use it
        target_include_directories(wx_bgi_wx_iface INTERFACE
            ${WX_INSTALL_DIR}/include
        )

    endif()
endif()