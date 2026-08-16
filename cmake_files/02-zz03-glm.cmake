# GET Source and Build Dependency - GLM

set(EP_BASE_GLM ${EP_BASE_PREFIX}/glm)
set(EP_BUILD_GLM ${EP_BUILD_PREFIX}/glm)
set(EP_INSTALL_GLM ${EP_INSTALL_PREFIX}/glm)

message(STATUS "Fetching GLM...")

set(GLM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLM_ENABLE_CXX_20 ON CACHE BOOL "" FORCE)
FetchContent_Declare(
    glm
    # # DOWNLOAD SOURCE CODE - GLM
    # URL https://github.com/g-truc/glm/archive/refs/tags/1.0.3.tar.gz
    # GIT PULL UPSTREAM - GLM
    GIT_REPOSITORY ${GIT_URL_GLM}
    GIT_TAG        ${GIT_TAG_GLM}
    GIT_SHALLOW    OFF    
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
        UPDATE_COMMAND
        ""
        PREFIX ${EP_BUILD_GLM}
        SOURCE_DIR ${EP_BASE_GLM}
        BINARY_DIR ${EP_INSTALL_GLM}     
)
FetchContent_MakeAvailable(glm)