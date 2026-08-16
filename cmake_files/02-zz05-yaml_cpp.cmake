# GET Source and Build Dependency - yaml_cpp

set(EP_BASE_YAML_CPP ${EP_BASE_PREFIX}/yaml_cpp)
set(EP_BUILD_YAML_CPP ${EP_BUILD_PREFIX}/yaml_cpp)
set(EP_INSTALL_YAML_CPP ${EP_INSTALL_PREFIX}/yaml_cpp)

message(STATUS "Fetching yaml_cpp...")

# yaml-cpp 0.8.0 uses cmake_minimum_required(VERSION 2.8.12) which CMake 4.0+
# rejects unless this policy variable is set.
set(CMAKE_POLICY_VERSION_MINIMUM "3.5" CACHE INTERNAL "")

set(YAML_CPP_BUILD_TESTS   OFF CACHE BOOL "" FORCE)
set(YAML_CPP_BUILD_TOOLS   OFF CACHE BOOL "" FORCE)
set(YAML_CPP_BUILD_CONTRIB OFF CACHE BOOL "" FORCE)
set(YAML_CPP_INSTALL       OFF CACHE BOOL "" FORCE)
set(CUSTOM_SOURCE_DIR_YAML_CPP ${FETCHCONTENT_BASE_DIR}/yaml-cpp-src CACHE INTERNAL "")
FetchContent_Declare(
    yaml_cpp
    # # DOWNLOAD BINARY - YAML_CPP
    # URL https://github.com/jbeder/yaml-cpp/releases/download/yaml-cpp-0.9.0/yaml-cpp-yaml-cpp-0.9.0.tar.gz
    # DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    # # # Patch_command runs a sed script to replace $$CMAKE_SOURCE_DIR with $$PROJECT_SOURCE_DIR in
    # # #    the yaml-cpp CMakeLists.txt file.
    # # PATCH_COMMAND
    # #     ${CMAKE_COMMAND} -E echo "Patching yaml-cpp CMakeLists.txt to replace {CMAKE_SOURCE_DIR} with ${CUSTOM_SOURCE_DIR_YAML_CPP}"
    # #     COMMAND ${CMAKE_COMMAND} -E env sed -i "s|PROJECT_SOURCE_DIR|CUSTOM_SOURCE_DIR_YAML_CPP|g" ${CUSTOM_SOURCE_DIR_YAML_CPP}/CMakeLists.txt
    # #     COMMAND ${CMAKE_COMMAND} -E echo "Modified CMakeLists.txt:"
    # #     COMMAND ${CMAKE_COMMAND} -E cat ${CUSTOM_SOURCE_DIR_YAML_CPP}/CMakeLists.txt
    # # DOWNLOAD SOURCE CODE - YAML_CPP
    # URL https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.9.0.tar.gz
    # GIT PULL UPSTREAM - YAML_CPP
    GIT_REPOSITORY ${GIT_URL_YAML_CPP}
    GIT_TAG        ${GIT_TAG_YAML_CPP}
    GIT_SHALLOW    OFF        
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    UPDATE_COMMAND
    ""
    PREFIX ${EP_BUILD_YAML_CPP}
    SOURCE_DIR ${EP_BASE_YAML_CPP}
    BINARY_DIR ${EP_INSTALL_YAML_CPP}         
)
FetchContent_MakeAvailable(yaml_cpp)