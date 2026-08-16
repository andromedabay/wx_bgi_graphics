# GET Source and Build Dependency - STB

set(EP_BASE_STB ${EP_BASE_PREFIX}/stb)
set(EP_BUILD_STB ${EP_BUILD_PREFIX}/stb)
set(EP_INSTALL_STB ${EP_INSTALL_PREFIX}/stb)

message(STATUS "Fetching stb...")

FetchContent_Declare(
    stb
    #GIT_REPOSITORY https://github.com/nothings/stb.git
    #GIT_TAG        master
    # GIT PULL UPSTREAM - STB
    GIT_REPOSITORY ${GIT_URL_STB}
    GIT_TAG        ${GIT_TAG_STB}
    GIT_SHALLOW    OFF        
    # NO DOWNLOAD SOURCE TAR BALL is PUBLISHED - STB
    # URL 
    UPDATE_COMMAND
    ""
    PREFIX ${EP_BUILD_STB}
    SOURCE_DIR ${EP_BASE_STB}
    BINARY_DIR ${EP_INSTALL_STB}      
)
FetchContent_MakeAvailable(stb)

# # START - Remove all within-target .git subfolders...
# execute_process(
#     COMMAND ${CMAKE_COMMAND} -E remove_directory ${EP_BASE_STB}/.git
# )
# # Remove any submodule .git directories
# execute_process(
#     COMMAND ${CMAKE_COMMAND} -E remove_directory ${EP_BASE_STB}/.git/modules
# )
# # Recursively remove any stray .git folders (submodules, nested repos)
# file(GLOB_RECURSE GIT_DIRS
#     "${EP_BASE_STB}/*/.git"
# )
# foreach(GITDIR ${GIT_DIRS})
#     message(STATUS "Removing Git metadata: ${GITDIR}")
#     execute_process(
#         COMMAND ${CMAKE_COMMAND} -E remove_directory ${GITDIR}
#     )
# endforeach()
# # END - Remove all within-target .git subfolders


# Create include prefix "stb/"
set(STB_INCLUDE_DIR ${FETCHCONTENT_BASE_DIR}/include_external/stb)
file(MAKE_DIRECTORY ${STB_INCLUDE_DIR})
# Copy the entire stb directory recursively
file(COPY ${stb_SOURCE_DIR}/ DESTINATION ${STB_INCLUDE_DIR})