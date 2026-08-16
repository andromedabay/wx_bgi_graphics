# GET Source and Build Dependency - nlohmann/json

set(EP_BASE_NLOHMANN_JSON ${EP_BASE_PREFIX}/nlohmann_json)
set(EP_BUILD_NLOHMANN_JSON ${EP_BUILD_PREFIX}/nlohmann_json)
set(EP_INSTALL_NLOHMANN_JSON ${EP_INSTALL_PREFIX}/nlohmann_json)

message(STATUS "Fetching nlohmann/json...")

set(JSON_BuildTests OFF CACHE BOOL "" FORCE)
set(JSON_Install    OFF CACHE BOOL "" FORCE)
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