if(NOT DEFINED HEADER_STAGING_DIR OR NOT DEFINED ROOT_SOURCE_DIR)
    message(FATAL_ERROR "StageHeaders.cmake requires HEADER_STAGING_DIR and ROOT_SOURCE_DIR")
endif()

file(GLOB_RECURSE WXBGI_PUBLIC_HEADERS
    "${ROOT_SOURCE_DIR}/*.h"
    "${ROOT_SOURCE_DIR}/*.hpp"
    "${ROOT_SOURCE_DIR}/*.hh"
    "${ROOT_SOURCE_DIR}/src/**/*.h"
    "${ROOT_SOURCE_DIR}/src/**/*.hpp"
    "${ROOT_SOURCE_DIR}/src/**/*.hh"
)

if(WXBGI_PUBLIC_HEADERS)
    list(SORT WXBGI_PUBLIC_HEADERS)
endif()

foreach(_header IN LISTS WXBGI_PUBLIC_HEADERS)
    if(NOT EXISTS "${_header}")
        continue()
    endif()

    if(_header MATCHES "^${ROOT_SOURCE_DIR}/src/")
        file(RELATIVE_PATH _rel_path "${ROOT_SOURCE_DIR}/src" "${_header}")
    else()
        file(RELATIVE_PATH _rel_path "${ROOT_SOURCE_DIR}" "${_header}")
    endif()
    set(_dest_path "${HEADER_STAGING_DIR}/${_rel_path}")
    get_filename_component(_dest_dir "${_dest_path}" DIRECTORY)
    file(MAKE_DIRECTORY "${_dest_dir}")
    configure_file("${_header}" "${_dest_path}" COPYONLY)
endforeach()
