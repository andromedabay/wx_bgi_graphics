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

        # FetchContent can leave behind stale clone metadata or partial worktrees
        # after an interrupted download. Remove the entire wxWidgets source/build
        # tree before each fresh fetch so the Git populate step does not reuse a
        # broken repository state or half-populated submodule metadata.
        # if(EXISTS "${EP_BASE_WXWIDGETS}")
        #     message(STATUS "Removing stale wxWidgets source tree before fetch.")
        #     file(REMOVE_RECURSE "${EP_BASE_WXWIDGETS}")
        #     #execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf "${EP_BASE_WXWIDGETS}")
        # endif()

        # Keep FetchContent prefix metadata/stamps intact. Removing this tree can
        # invalidate generated populate stamp files in the current build dir.

        set(wxBUILD_SHARED  OFF CACHE BOOL "" FORCE)
        set(wxBUILD_TESTS   OFF CACHE STRING "" FORCE)
        set(wxBUILD_SAMPLES OFF CACHE STRING "" FORCE)
        set(wxBUILD_DEMOS   OFF CACHE STRING "" FORCE)
        set(wxBUILD_STC    OFF CACHE BOOL "" FORCE)
        set(wxUSE_STC      OFF CACHE BOOL "" FORCE)
        set(wxBUILD_INSTALL_LOCALE OFF CACHE BOOL "" FORCE)

        if(APPLE)
            # wxWidgets 3.2.x bundles libpng which includes <fp.h>. That header was
            # removed from macOS SDKs in Xcode 15+ (macOS Sonoma/Sequoia). Use the
            # macOS system libpng to avoid the build error.
            set(wxUSE_LIBPNG sys CACHE STRING "" FORCE)
        endif()

        # Prefer the release archive to avoid recursive git submodule cloning,
        # which is fragile in constrained/proxied network environments.
        string(REGEX REPLACE "^v" "" _wxwidgets_version "${GIT_TAG_WXWIDGETS}")
        set(_wxwidgets_release_url "https://github.com/wxWidgets/wxWidgets/releases/download/${GIT_TAG_WXWIDGETS}/wxWidgets-${_wxwidgets_version}.tar.bz2")
        set(_wxwidgets_fallback_url "https://github.com/wxWidgets/wxWidgets/archive/refs/tags/${GIT_TAG_WXWIDGETS}.tar.gz")

        FetchContent_Declare(
            wxwidgets
            URL ${_wxwidgets_release_url} ${_wxwidgets_fallback_url}
            DOWNLOAD_EXTRACT_TIMESTAMP TRUE
            UPDATE_COMMAND ""
            PREFIX ${EP_BUILD_WXWIDGETS}
            SOURCE_DIR ${EP_BASE_WXWIDGETS}
            BINARY_DIR ${EP_INSTALL_WXWIDGETS}
        )

        FetchContent_GetProperties(wxwidgets)
        if(NOT wxwidgets_POPULATED)
            FetchContent_Populate(wxwidgets)
        endif()

        set(_wxwidgets_effective_source_dir "${wxwidgets_SOURCE_DIR}")
        if(NOT EXISTS "${_wxwidgets_effective_source_dir}/include/wx/version.h")
            file(GLOB _wxwidgets_source_dir_candidates LIST_DIRECTORIES true
                "${wxwidgets_SOURCE_DIR}/wxWidgets-*"
                "${wxwidgets_SOURCE_DIR}/wxwidgets-*"
            )
            foreach(_wxwidgets_candidate IN LISTS _wxwidgets_source_dir_candidates)
                if(EXISTS "${_wxwidgets_candidate}/include/wx/version.h")
                    set(_wxwidgets_effective_source_dir "${_wxwidgets_candidate}")
                    break()
                endif()
            endforeach()
        endif()

        if(NOT EXISTS "${_wxwidgets_effective_source_dir}/include/wx/version.h")
            message(FATAL_ERROR
                "wxWidgets archive was populated but expected headers are missing at ${wxwidgets_SOURCE_DIR}. "
                "If network restrictions persist, retry with -DWXBGI_SYSTEM_WX=ON after installing system wxWidgets."
            )
        endif()

        if(NOT "${_wxwidgets_effective_source_dir}" STREQUAL "${wxwidgets_SOURCE_DIR}")
            message(STATUS "Using nested wxWidgets source root: ${_wxwidgets_effective_source_dir}")
        endif()

        add_subdirectory(${_wxwidgets_effective_source_dir} ${wxwidgets_BINARY_DIR})

        target_link_libraries(wx_bgi_wx_iface INTERFACE wxcore wxgl wxbase)

        # Do not force a full wxWidgets install for the fetched build. The
        # install step tries to package locale files that are not generated in
        # this configuration, and the library only needs the built targets and
        # their include paths.
        target_include_directories(wx_bgi_wx_iface INTERFACE
            ${_wxwidgets_effective_source_dir}/include
            ${wxwidgets_BINARY_DIR}/include
        )

        include_directories(${glew_SOURCE_DIR}/include)

    endif()
endif()