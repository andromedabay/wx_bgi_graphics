set(WXBGI_PACKAGE_ROOT "${CMAKE_BINARY_DIR}/artifacts")
set(WXBGI_HEADER_STAGING_DIR "${WXBGI_PACKAGE_ROOT}/headers_staging")
set(WXBGI_HEADERS_ZIP "${WXBGI_PACKAGE_ROOT}/wx_bgi_headers.zip")
set(WXBGI_HEADERS_TAR_GZ "${WXBGI_PACKAGE_ROOT}/wx_bgi_headers.tar.gz")
set(WXBGI_BIN_DIR "${WXBGI_PACKAGE_ROOT}/bin")
set(WXBGI_LIB_DIR "${WXBGI_PACKAGE_ROOT}/lib")
set(WXBGI_DOCS_DIR "${WXBGI_PACKAGE_ROOT}/docs")

file(MAKE_DIRECTORY
    "${WXBGI_PACKAGE_ROOT}"
    "${WXBGI_HEADER_STAGING_DIR}"
    "${WXBGI_BIN_DIR}"
    "${WXBGI_LIB_DIR}"
    "${WXBGI_DOCS_DIR}"
)

get_property(WXBGI_ALL_TARGETS DIRECTORY PROPERTY BUILDSYSTEM_TARGETS)
set(WXBGI_PACKAGE_DEPS wx_bgi_opengl)
foreach(_target IN LISTS WXBGI_ALL_TARGETS)
    if(TARGET "${_target}")
        get_target_property(_target_type "${_target}" TYPE)
        if(_target_type STREQUAL "EXECUTABLE")
            list(APPEND WXBGI_PACKAGE_DEPS "${_target}")
        endif()
    endif()
endforeach()
list(REMOVE_DUPLICATES WXBGI_PACKAGE_DEPS)

add_custom_target(wx_bgi_headers_package ALL
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${WXBGI_PACKAGE_ROOT}"
    COMMAND ${CMAKE_COMMAND} -E make_directory
            "${WXBGI_HEADER_STAGING_DIR}"
            "${WXBGI_BIN_DIR}"
            "${WXBGI_LIB_DIR}"
            "${WXBGI_DOCS_DIR}"
    COMMAND ${CMAKE_COMMAND} -E echo "Staging public headers for packaging"
    COMMAND ${CMAKE_COMMAND} -DROOT_SOURCE_DIR=${CMAKE_SOURCE_DIR} -DHEADER_STAGING_DIR=${WXBGI_HEADER_STAGING_DIR} -P ${CMAKE_SOURCE_DIR}/cmake/07-zz01-StageHeaders.cmake
    COMMENT "Packaging public headers, binaries, and docs into the build artifacts directory"
    VERBATIM
)

#add_dependencies(wx_bgi_headers_package wxwidgets_install)

if(TARGET api_docs)
    add_dependencies(wx_bgi_headers_package api_docs)
endif()
add_dependencies(wx_bgi_headers_package ${WXBGI_PACKAGE_DEPS})

add_custom_command(TARGET wx_bgi_headers_package POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:wx_bgi_opengl>
            "${WXBGI_LIB_DIR}/$<TARGET_FILE_NAME:wx_bgi_opengl>"
    VERBATIM
)

if(EXISTS "${CMAKE_BINARY_DIR}/libwx_bgi_opengl.so")
    add_custom_command(TARGET wx_bgi_headers_package POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_BINARY_DIR}/libwx_bgi_opengl.so"
                "${WXBGI_LIB_DIR}/libwx_bgi_opengl.so"
        VERBATIM
    )
endif()

file(GLOB_RECURSE WXBGI_PDF_DOCS CONFIGURE_DEPENDS "${CMAKE_BINARY_DIR}/**/*.pdf")
foreach(_pdf_doc IN LISTS WXBGI_PDF_DOCS)
    file(RELATIVE_PATH _pdf_rel_path "${CMAKE_BINARY_DIR}" "${_pdf_doc}")
    get_filename_component(_pdf_rel_dir "${_pdf_rel_path}" DIRECTORY)
    add_custom_command(TARGET wx_bgi_headers_package POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${WXBGI_DOCS_DIR}/${_pdf_rel_dir}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${_pdf_doc}"
                "${WXBGI_DOCS_DIR}/${_pdf_rel_path}"
        VERBATIM
    )
endforeach()

foreach(_target IN LISTS WXBGI_PACKAGE_DEPS)
    if(NOT "${_target}" STREQUAL "wx_bgi_opengl")
        add_custom_command(TARGET wx_bgi_headers_package POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:${_target}>
                    "${WXBGI_BIN_DIR}/$<TARGET_FILE_NAME:${_target}>"
            VERBATIM
        )
    endif()
endforeach()

# HEADERS.ZIP must run AFTER all POST_BUILD copies
message(STATUS "Creating wx_bgi_headers.zip")
add_custom_command(TARGET wx_bgi_headers_package POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E chdir "${WXBGI_HEADER_STAGING_DIR}"
            ${CMAKE_COMMAND} -E tar "cf" "${WXBGI_HEADERS_ZIP}" --format=zip -- .
)

# HEADERS.TAR.GZ must run AFTER all POST_BUILD copies
message(STATUS "Creating wx_bgi_headers.tar.gz")
add_custom_command(TARGET wx_bgi_headers_package POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E chdir "${WXBGI_HEADER_STAGING_DIR}"
            ${CMAKE_COMMAND} -E tar "czf" "${WXBGI_HEADERS_TAR_GZ}" --format=gnutar -- .
)
    
set_property(TARGET wx_bgi_headers_package PROPERTY FOLDER "Packaging")
