# GET Source and Build Dependency - GLFW

set(EP_BASE_GLFW ${EP_BASE_PREFIX}/glfw)
set(EP_BUILD_GLFW ${EP_BUILD_PREFIX}/glfw)
set(EP_INSTALL_GLFW ${EP_INSTALL_PREFIX}/glfw)

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
    set(GLFW_INSTALL ON CACHE BOOL "" FORCE)

    # FetchContent_Declare(
    #    glfw
    #     URL https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz
    #     DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    # )
    # FetchContent_MakeAvailable(glfw)

    # FetchContent_Declare(
    #     glfw
    #     GIT_REPOSITORY
    #     https://github.com/glfw/glfw.git
    #     GIT_TAG
    #     3.5.1
    #     UPDATE_COMMAND
    #     ""
    #     PREFIX ${EP_BUILD_GLFW}
    #     SOURCE_DIR ${EP_BASE_GLFW}
    #     INSTALL_DIR ${EP_INSTALL_GLFW}        
    # )
    # FetchContent_MakeAvailable(glfw)

    FetchContent_Declare(
       glfw
        # # Download Source Code - GLFW
        # URL https://github.com/glfw/glfw/archive/refs/tags/3.5.1.tar.gz
        # GIT PULL UPSTREAM - GLFW
        GIT_REPOSITORY ${GIT_URL_GLFW}
        GIT_TAG        ${GIT_TAG_GLFW}
        GIT_SHALLOW    OFF           
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        UPDATE_COMMAND
        ""
        PREFIX ${EP_BUILD_GLFW}
        SOURCE_DIR ${EP_BASE_GLFW}
        INSTALL_DIR ${EP_INSTALL_GLFW}        
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

