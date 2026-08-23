# Set ThirdParties (Dependencies) for wxBGI_Graphics_Lib

# ExternalProject base
set(EP_BASE_PREFIX ${PROJECT_SOURCE_DIR}/third_party/src)

# ExternalProject Installed Base
set(EP_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/third_party/installed)

# ExternalProject Build Base
set(EP_BUILD_PREFIX ${CMAKE_BINARY_DIR}/third_party/build)

message(STATUS "Getting ThirdParty dependencies for wxBGI_Graphics_Lib...")
#-------
include(cmake_files/02-zz01-glew.cmake)
include(cmake_files/02-zz02-glfw.cmake)
include(cmake_files/02-zz03-glm.cmake)
include(cmake_files/02-zz04-nlohmann_json.cmake)
include(cmake_files/02-zz05-yaml_cpp.cmake)
include(cmake_files/02-zz06-manifold.cmake)
include(cmake_files/02-zz07-stb.cmake)
include(cmake_files/02-zz08-wxwidgets.cmake)

message(STATUS "ThirdParty source base: ${EP_BASE_PREFIX}")
message(STATUS "ThirdParty installed base: ${EP_INSTALL_PREFIX}")
message(STATUS "ThirdParty build base: ${EP_BUILD_PREFIX}")
message(STATUS "ThirdParty dependencies for wxBGI_Graphics_Lib are ready.")
