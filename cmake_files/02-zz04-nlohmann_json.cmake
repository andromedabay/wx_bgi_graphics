# GET Source and Build Dependency - nlohmann/json

set(EP_BASE_NLOHMANN_JSON ${EP_BASE_PREFIX}/nlohmann_json)
set(EP_BUILD_NLOHMANN_JSON ${EP_BUILD_PREFIX}/nlohmann_json)
set(EP_INSTALL_NLOHMANN_JSON ${EP_INSTALL_PREFIX}/nlohmann_json)

message(STATUS "Fetching nlohmann/json...")

set(JSON_BuildTests OFF CACHE BOOL "" FORCE)
set(JSON_Install    ON CACHE BOOL "" FORCE)
FetchContent_Declare(
    nlohmann_json
    # # DOWNLOAD BINARY - nlohmann_json
    # URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
    # # DOWNLOAD SOURCE CODE - nlohmann_json
    # URL https://github.com/nlohmann/json/archive/refs/tags/v3.12.0.tar.gz
    # GIT PULL UPSTREAM - NLOHMANN_JSON
    GIT_REPOSITORY ${GIT_URL_NLOHMANN_JSON}
    GIT_TAG        ${GIT_TAG_NLOHMANN_JSON}
    GIT_SHALLOW    OFF        
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    UPDATE_COMMAND
    ""
    PREFIX ${EP_BUILD_NLOHMANN_JSON}
    SOURCE_DIR ${EP_BASE_NLOHMANN_JSON}
    BINARY_DIR ${EP_INSTALL_NLOHMANN_JSON}         
)
FetchContent_MakeAvailable(nlohmann_json)

if(NOT TARGET nlohmann_json::nlohmann_json)
    if(TARGET nlohmann_json)
        add_library(nlohmann_json::nlohmann_json ALIAS nlohmann_json)
    else()
        add_library(nlohmann_json::nlohmann_json INTERFACE IMPORTED GLOBAL)
        set_target_properties(nlohmann_json::nlohmann_json PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES
                "${nlohmann_json_SOURCE_DIR}/include;${nlohmann_json_SOURCE_DIR}/single_include"
        )
    endif()
endif()