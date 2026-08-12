# GET Source and Build Dependency - GLEW

set(EP_BASE_GLEW ${EP_BASE_PREFIX}/glew)
set(EP_BUILD_GLEW ${EP_BUILD_PREFIX}/glew)
set(EP_INSTALL_GLEW ${EP_INSTALL_PREFIX}/glew)

# file(GLOB RESULT ${EP_BASE_GLEW})
# list(LENGTH RESULT RES_LEN)
# if(RES_LEN EQUAL 0)
#     message(STATUS "Fetching GLEW...")
#     include(ExternalProject)
#     ExternalProject_Add(
#         glew
#         GIT_REPOSITORY
#         https://github.com/nigels-com/glew.git
#         GIT_TAG
#         glew-2.3.1
#         UPDATE_COMMAND
#         ""
#         PREFIX ${EP_BUILD_GLEW}
#         SOURCE_DIR ${EP_BASE_GLEW}
#         INSTALL_DIR ${EP_INSTALL_GLEW}
#     )
# endif()


FetchContent_Declare(
   glew
   URL https://github.com/nigels-com/glew/releases/download/glew-2.3.1/glew-2.3.1.tgz
   DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)
FetchContent_MakeAvailable(glew)