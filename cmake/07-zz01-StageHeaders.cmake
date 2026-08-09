if(NOT DEFINED HEADER_STAGING_DIR OR NOT DEFINED ROOT_SOURCE_DIR)
    message(FATAL_ERROR "StageHeaders.cmake requires HEADER_STAGING_DIR and ROOT_SOURCE_DIR")
endif()

set(wxWidgets_headers "${CMAKE_BINARY_DIR}/_deps_fc/wxwidgets-src/include")
set(glew_headers "${CMAKE_BINARY_DIR}/_deps_fc/glew-src/include")
set(glfw_headers "${CMAKE_BINARY_DIR}/_deps_fc/glfw-src/include")
set(glm_headers "${CMAKE_BINARY_DIR}/_deps_fc/glm-src")
set(manifold_headers "${CMAKE_BINARY_DIR}/_deps_fc/manifold-src/include")
set(nlohmann_headers "${CMAKE_BINARY_DIR}/_deps_fc/nlohmann-src/include")
set(yaml-cpp_headers "${CMAKE_BINARY_DIR}/_deps_fc/yaml-cpp-src/include")
set(stb_headers "${CMAKE_BINARY_DIR}/_deps_fc/stb-src")


file(GLOB_RECURSE WXBGI_PUBLIC_HEADERS
    "${ROOT_SOURCE_DIR}/src/*.h"
    "${ROOT_SOURCE_DIR}/src/*.hpp"
    "${ROOT_SOURCE_DIR}/src/*.hh"
    "${ROOT_SOURCE_DIR}/src/**/*.h"
    "${ROOT_SOURCE_DIR}/src/**/*.hpp"
    "${ROOT_SOURCE_DIR}/src/**/*.hh"
    "${wxWidgets_headers}/**/*.h"
    "${wxWidgets_headers}/**/*.hpp"
    "${wxWidgets_headers}/**/*.hh"
    "${glew_headers}/**/*.h"
    "${glew_headers}/**/*.hpp"
    "${glew_headers}/**/*.hh"
    "${glfw_headers}/**/*.h"
    "${glfw_headers}/**/*.hpp"
    "${glfw_headers}/**/*.hh"
    "${glm_headers}/glm/*.h"
    "${glm_headers}/glm/*.hpp"
    "${glm_headers}/glm/*.hh"    
    "${glm_headers}/glm/**/*.h"
    "${glm_headers}/glm/**/*.hpp"
    "${glm_headers}/glm/**/*.hh"
    "${manifold_headers}/**/*.h"
    "${manifold_headers}/**/*.hpp"
    "${manifold_headers}/**/*.hh"
    "${nlohmann_headers}/**/*.h"
    "${nlohmann_headers}/**/*.hpp"
    "${nlohmann_headers}/**/*.hh"
    "${yaml-cpp_headers}/**/*.h"
    "${yaml-cpp_headers}/**/*.hpp"
    "${yaml-cpp_headers}/**/*.hh"
    "${stb_headers}/*.h"
    "${stb_headers}/*.hpp"
    "${stb_headers}/*.hh"
    "${stb_headers}/**/*.h"
    "${stb_headers}/**/*.hpp"
    "${stb_headers}/**/*.hh"
)

set(REL_HEADERS "")

foreach(hdr ${WXBGI_PUBLIC_HEADERS})

    # --- wxWidgets headers: preserve structure ---
    if(hdr MATCHES "^${wxWidgets_headers}/")
        file(RELATIVE_PATH rel_src "${wxWidgets_headers}" "${hdr}")
        set(rel_dst "${rel_src}")   # same structure
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")
        continue()
    endif()

    # --- STB headers: preserve structure ---
    if(hdr MATCHES "^${stb_headers}/")
        file(RELATIVE_PATH rel_src "${stb_headers}" "${hdr}")
        set(rel_dst "${rel_src}")   # same structure
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")
        continue()
    endif()

    # --- GLEW headers: preserve structure ---
    if(hdr MATCHES "^${glew_headers}/")
        get_filename_component(filename "${CMAKE_BINARY_DIR}" NAME)
        file(RELATIVE_PATH rel_src "${CMAKE_BINARY_DIR}" "${hdr}")
        set(rel_src "${filename}/${rel_src}")  # prepend the binary dir name
        file(RELATIVE_PATH rel_dst "${glew_headers}" "${hdr}")
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")
        continue()
    endif()

    # --- GLFW headers: preserve structure ---
    if(hdr MATCHES "^${glfw_headers}/")
        get_filename_component(filename "${CMAKE_BINARY_DIR}" NAME)
        file(RELATIVE_PATH rel_src "${CMAKE_BINARY_DIR}" "${hdr}")
        set(rel_src "${filename}/${rel_src}")  # prepend the binary dir name
        file(RELATIVE_PATH rel_dst "${glfw_headers}" "${hdr}")
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")
        continue()
    endif()

    # --- GLM headers: preserve structure ---
    if(hdr MATCHES "^${glm_headers}/")
        get_filename_component(filename "${CMAKE_BINARY_DIR}" NAME)
        file(RELATIVE_PATH rel_src "${CMAKE_BINARY_DIR}" "${hdr}")
        set(rel_src "${filename}/${rel_src}")  # prepend the binary dir name
        file(RELATIVE_PATH rel_dst "${glm_headers}" "${hdr}")
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")
        continue()
    endif()

    # --- MANIFOLD headers: preserve structure ---
    if(hdr MATCHES "^${manifold_headers}/")
        get_filename_component(filename "${CMAKE_BINARY_DIR}" NAME)
        file(RELATIVE_PATH rel_src "${CMAKE_BINARY_DIR}" "${hdr}")
        set(rel_src "${filename}/${rel_src}")  # prepend the binary dir name
        file(RELATIVE_PATH rel_dst "${manifold_headers}" "${hdr}")
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")
        continue()
    endif()    

    # --- YAML-CPP headers: preserve structure ---
    if(hdr MATCHES "^${yaml-cpp_headers}/")
        get_filename_component(filename "${CMAKE_BINARY_DIR}" NAME)
        file(RELATIVE_PATH rel_src "${CMAKE_BINARY_DIR}" "${hdr}")
        set(rel_src "${filename}/${rel_src}")  # prepend the binary dir name
        file(RELATIVE_PATH rel_dst "${yaml-cpp_headers}" "${hdr}")
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")
        continue()
    endif()   

    # --- This Project (wx_bgi) source headers ----
    if(hdr MATCHES "${ROOT_SOURCE_DIR}/src/")
        file(RELATIVE_PATH rel_src "${ROOT_SOURCE_DIR}" "${hdr}")
        string(REGEX REPLACE "^src/" "" rel_dst "${rel_src}")
        list(APPEND REL_HEADERS "${rel_src}|${rel_dst}")     
        continue()
    endif()


endforeach()

list(SORT REL_HEADERS)

foreach(pair IN LISTS REL_HEADERS)

    # Split "rel_src|rel_dst"
    string(REPLACE "|" ";" parts "${pair}")
    list(GET parts 0 rel_src)
    list(GET parts 1 rel_dst)

    # Determine actual source path
    if(EXISTS "${wxWidgets_headers}/${rel_src}")
        set(src "${wxWidgets_headers}/${rel_src}")
        set(dest "${HEADER_STAGING_DIR}/${rel_dst}")
    elseif(EXISTS "${stb_headers}/${rel_src}")
        set(src "${stb_headers}/${rel_src}")
        set(dest "${HEADER_STAGING_DIR}/stb/${rel_dst}")
    else()
        set(src "${ROOT_SOURCE_DIR}/${rel_src}")
        set(dest "${HEADER_STAGING_DIR}/${rel_dst}")
    endif()

    get_filename_component(dest_dir "${dest}" DIRECTORY)
    file(MAKE_DIRECTORY "${dest_dir}")

    configure_file("${src}" "${dest}" COPYONLY)

endforeach()
