set(WXBGI_PACKAGE_ROOT "${CMAKE_BINARY_DIR}/artifacts")
set(WXBGI_HEADER_STAGING_DIR "${WXBGI_PACKAGE_ROOT}/headers_staging")
set(WXBGI_HEADERS_ZIP "${WXBGI_PACKAGE_ROOT}/wx_bgi_headers.zip")
set(WXBGI_HEADERS_TAR_GZ "${WXBGI_PACKAGE_ROOT}/wx_bgi_headers.tar.gz")
set(WXBGI_BIN_DIR "${WXBGI_PACKAGE_ROOT}/bin")
set(WXBGI_LIB_DIR "${WXBGI_PACKAGE_ROOT}/lib")
set(WXBGI_DOCS_DIR "${WXBGI_PACKAGE_ROOT}/docs")
set(WXBGI_PACKAGE_STAMP "${WXBGI_PACKAGE_ROOT}/.package_stamp")
get_target_property(_wx_bgi_output_name wx_bgi_graphics OUTPUT_NAME)
if(NOT _wx_bgi_output_name)
    set(_wx_bgi_output_name "wx_bgi_graphics")
endif()
if(WXBGI_BUILD_SHARED)
    set(_wx_bgi_lib_file "${_wx_bgi_output_name}${CMAKE_SHARED_LIBRARY_SUFFIX}")
else()
    set(_wx_bgi_lib_file "${_wx_bgi_output_name}${CMAKE_STATIC_LIBRARY_SUFFIX}")
endif()
set(WXBGI_PACKAGE_ARTIFACTS
    "${WXBGI_HEADERS_ZIP}"
    "${WXBGI_HEADERS_TAR_GZ}"
    "${WXBGI_LIB_DIR}/${_wx_bgi_lib_file}"
)

file(MAKE_DIRECTORY
    "${WXBGI_PACKAGE_ROOT}"
    "${WXBGI_HEADER_STAGING_DIR}"
    "${WXBGI_BIN_DIR}"
    "${WXBGI_LIB_DIR}"
    "${WXBGI_DOCS_DIR}"
)

set(WXBGI_PACKAGE_DEPENDENCIES
    wx_bgi_graphics
)
if(WXBGI_INSTALL_DOCS AND TARGET api_docs)
    list(APPEND WXBGI_PACKAGE_DEPENDENCIES api_docs)
endif()
list(REMOVE_DUPLICATES WXBGI_PACKAGE_DEPENDENCIES)

set(WXBGI_PROJECT_PUBLIC_ROOT "${CMAKE_SOURCE_DIR}/src")
set(WXBGI_GLEW_INCLUDE_ROOT "${glew_SOURCE_DIR}/include")
set(WXBGI_GLFW_STAGE_PREFIX "")
if(WXBGI_SYSTEM_GLFW)
    get_target_property(_glfw_include_dirs glfw INTERFACE_INCLUDE_DIRECTORIES)
    if(NOT _glfw_include_dirs)
        message(FATAL_ERROR "System GLFW is enabled but target glfw does not expose any include directories")
    endif()

    set(WXBGI_GLFW_INCLUDE_ROOT "")
    foreach(_glfw_include_dir IN LISTS _glfw_include_dirs)
        if(EXISTS "${_glfw_include_dir}/GLFW/glfw3.h")
            set(WXBGI_GLFW_INCLUDE_ROOT "${_glfw_include_dir}/GLFW")
            set(WXBGI_GLFW_STAGE_PREFIX "GLFW")
            break()
        endif()
        if(EXISTS "${_glfw_include_dir}/glfw3.h")
            set(WXBGI_GLFW_INCLUDE_ROOT "${_glfw_include_dir}")
            set(WXBGI_GLFW_STAGE_PREFIX "GLFW")
            break()
        endif()
    endforeach()

    if(WXBGI_GLFW_INCLUDE_ROOT STREQUAL "")
        list(GET _glfw_include_dirs 0 _glfw_include_dir)
        message(FATAL_ERROR
            "Could not locate GLFW headers under the imported target include directories: ${_glfw_include_dirs}. "
            "Expected to find either GLFW/glfw3.h or glfw3.h under ${_glfw_include_dir}."
        )
    endif()
else()
    set(WXBGI_GLFW_INCLUDE_ROOT "${glfw_SOURCE_DIR}/include")
endif()
set(WXBGI_GLM_INCLUDE_ROOT "${glm_SOURCE_DIR}")
set(WXBGI_MANIFOLD_INCLUDE_ROOT "${manifold_SOURCE_DIR}/include")
set(WXBGI_NLOHMANN_JSON_INCLUDE_ROOT "${nlohmann_json_SOURCE_DIR}/include")
set(WXBGI_YAML_CPP_INCLUDE_ROOT "${EP_BASE_YAML_CPP}/include")
set(WXBGI_STB_SOURCE_ROOT "${stb_SOURCE_DIR}")
set(WXBGI_WXWIDGETS_STAGE_ARG "")
if(WXBGI_ENABLE_WX)
    set(WXBGI_WXWIDGETS_SOURCE_ROOT "${wxwidgets_SOURCE_DIR}")
    set(WXBGI_WXWIDGETS_STAGE_ARG "-DWXWIDGETS_SOURCE_ROOT=${WXBGI_WXWIDGETS_SOURCE_ROOT}")
endif()

add_custom_command(
    OUTPUT "${WXBGI_PACKAGE_STAMP}"
    BYPRODUCTS ${WXBGI_PACKAGE_ARTIFACTS}
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${WXBGI_PACKAGE_ROOT}"
    COMMAND ${CMAKE_COMMAND} -E make_directory
            "${WXBGI_HEADER_STAGING_DIR}"
            "${WXBGI_BIN_DIR}"
            "${WXBGI_LIB_DIR}"
            "${WXBGI_DOCS_DIR}"
        COMMAND ${CMAKE_COMMAND}
            -DHEADER_STAGING_DIR=${WXBGI_HEADER_STAGING_DIR}
            -DPROJECT_PUBLIC_ROOT=${WXBGI_PROJECT_PUBLIC_ROOT}
            -DGLEW_INCLUDE_ROOT=${WXBGI_GLEW_INCLUDE_ROOT}
            -DGLFW_INCLUDE_ROOT=${WXBGI_GLFW_INCLUDE_ROOT}
            -DGLFW_STAGE_PREFIX=${WXBGI_GLFW_STAGE_PREFIX}
            -DGLM_INCLUDE_ROOT=${WXBGI_GLM_INCLUDE_ROOT}
            -DMANIFOLD_INCLUDE_ROOT=${WXBGI_MANIFOLD_INCLUDE_ROOT}
            -DNLOHMANN_JSON_INCLUDE_ROOT=${WXBGI_NLOHMANN_JSON_INCLUDE_ROOT}
            -DYAML_CPP_INCLUDE_ROOT=${WXBGI_YAML_CPP_INCLUDE_ROOT}
            -DSTB_SOURCE_ROOT=${WXBGI_STB_SOURCE_ROOT}
                ${WXBGI_WXWIDGETS_STAGE_ARG}
                -DWXBGI_ENABLE_WX=${WXBGI_ENABLE_WX}
            -P ${CMAKE_SOURCE_DIR}/cmake_files/08-zz01-StageHeaders.cmake
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:wx_bgi_graphics>"
            "${WXBGI_LIB_DIR}/${_wx_bgi_lib_file}"
    COMMAND ${CMAKE_COMMAND} -E echo "Packaging public headers into zip and tar archives"
    COMMAND ${CMAKE_COMMAND} -E chdir "${WXBGI_HEADER_STAGING_DIR}"
            ${CMAKE_COMMAND} -E tar "cf" "${WXBGI_HEADERS_ZIP}" --format=zip -- .
    COMMAND ${CMAKE_COMMAND} -E chdir "${WXBGI_HEADER_STAGING_DIR}"
            ${CMAKE_COMMAND} -E tar "czf" "${WXBGI_HEADERS_TAR_GZ}" --format=gnutar -- .
    COMMAND ${CMAKE_COMMAND} -E touch "${WXBGI_PACKAGE_STAMP}"
    DEPENDS ${WXBGI_PACKAGE_DEPENDENCIES}
    COMMENT "Packaging public headers, binaries, and docs into the build artifacts directory"
    VERBATIM
)

add_custom_target(wx_bgi_headers_package
    DEPENDS "${WXBGI_PACKAGE_STAMP}"
    COMMENT "Generate staged headers and packaged artifacts"
    VERBATIM
)

file(GLOB_RECURSE WXBGI_PDF_DOCS CONFIGURE_DEPENDS "${CMAKE_BINARY_DIR}/**/*.pdf")
foreach(_pdf_doc IN LISTS WXBGI_PDF_DOCS)
    file(RELATIVE_PATH _pdf_rel_path "${CMAKE_BINARY_DIR}" "${_pdf_doc}")
    get_filename_component(_pdf_rel_dir "${_pdf_rel_path}" DIRECTORY)
    add_custom_command(
        TARGET wx_bgi_headers_package POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${WXBGI_DOCS_DIR}/${_pdf_rel_dir}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${_pdf_doc}"
                "${WXBGI_DOCS_DIR}/${_pdf_rel_path}"
        VERBATIM
    )
endforeach()

set_property(TARGET wx_bgi_headers_package PROPERTY FOLDER "Packaging")
