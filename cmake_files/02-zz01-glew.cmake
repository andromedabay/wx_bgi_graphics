# GET Source and Build Dependency - GLEW

set(EP_BASE_GLEW ${EP_BASE_PREFIX}/glew)
set(EP_BUILD_GLEW ${EP_BUILD_PREFIX}/glew)
set(EP_INSTALL_GLEW ${EP_INSTALL_PREFIX}/glew)

set(GLEW_USE_STATIC_LIBS ON CACHE BOOL "" FORCE)
set(GLEW_BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

message (STATUS "Fetching GLEW...")

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
   # # Download Compiled Binary Release - GLEW
   # URL https://github.com/nigels-com/glew/releases/download/glew-2.3.1/glew-2.3.1.tgz
   # # Download Source Code - GLEW
   # URL https://github.com/nigels-com/glew/archive/refs/tags/glew-2.3.1.tar.gz
   # GIT PULL UPSTREAM - GLEW
   GIT_REPOSITORY ${GIT_URL_GLEW}
   GIT_TAG        ${GIT_TAG_GLEW}
   GIT_SHALLOW    OFF   
   DOWNLOAD_EXTRACT_TIMESTAMP TRUE
   CONFIGURE_COMMAND "cmake -Hbuild/cmake -Bout/build/glew -DCMAKE_INSTALL_PREFIX=${EP_INSTALL_GLEW} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DBUILD_SHARED_LIBS=${GLEW_BUILD_SHARED_LIBS} -DGLEW_USE_STATIC_LIBS=${GLEW_USE_STATIC_LIBS}"
   BUILD_COMMAND "cmake --build out/build/glew --config ${CMAKE_BUILD_TYPE} --target install"
   UPDATE_COMMAND
      ""
   PREFIX ${EP_BUILD_GLEW}
   SOURCE_DIR ${EP_BASE_GLEW}
   BINARY_DIR ${EP_INSTALL_GLEW}      
)
FetchContent_MakeAvailable(glew)
