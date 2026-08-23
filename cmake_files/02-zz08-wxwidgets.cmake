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

        target_link_libraries(wx_bgi_wx_iface INTERFACE wxcore wxgl wxbase)

        # Do not force a full wxWidgets install for the fetched build. The
        # install step tries to package locale files that are not generated in
        # this configuration, and the library only needs the built targets and
        # their include paths.
        target_include_directories(wx_bgi_wx_iface INTERFACE
            ${wxWidgets_SOURCE_DIR}/include
            ${wxWidgets_BINARY_DIR}/include
        )

        include_directories(${glew_SOURCE_DIR}/include)

    endif()
endif()