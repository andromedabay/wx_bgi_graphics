if(NOT DEFINED HEADER_STAGING_DIR)
    message(FATAL_ERROR "StageHeaders.cmake requires HEADER_STAGING_DIR")
endif()

if(NOT DEFINED PROJECT_PUBLIC_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires PROJECT_PUBLIC_ROOT")
endif()

if(NOT DEFINED GLEW_INCLUDE_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires GLEW_INCLUDE_ROOT")
endif()

if(NOT DEFINED GLFW_INCLUDE_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires GLFW_INCLUDE_ROOT")
endif()

if(NOT DEFINED GLM_INCLUDE_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires GLM_INCLUDE_ROOT")
endif()

if(NOT DEFINED MANIFOLD_INCLUDE_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires MANIFOLD_INCLUDE_ROOT")
endif()

if(NOT DEFINED NLOHMANN_JSON_INCLUDE_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires NLOHMANN_JSON_INCLUDE_ROOT")
endif()

if(NOT DEFINED YAML_CPP_INCLUDE_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires YAML_CPP_INCLUDE_ROOT")
endif()

if(NOT DEFINED STB_SOURCE_ROOT)
    message(FATAL_ERROR "StageHeaders.cmake requires STB_SOURCE_ROOT")
endif()

if(NOT DEFINED WXBGI_ENABLE_WX)
    set(WXBGI_ENABLE_WX ON)
endif()

file(MAKE_DIRECTORY "${HEADER_STAGING_DIR}")

function(wxbgi_stage_headers_from_root source_root destination_prefix label)
    set(header_patterns
        "*.h"
        "*.hpp"
        "*.hh"
        "*.inl"
        "*.ipp"
    )

    if(NOT EXISTS "${source_root}")
        message(FATAL_ERROR "${label} source root does not exist: ${source_root}")
    endif()

    set(stage_root "${source_root}")
    if(label STREQUAL "wxWidgets")
        if(EXISTS "${stage_root}/include/wx/version.h")
            set(stage_root "${stage_root}/include")
        elseif(EXISTS "${stage_root}/wx/version.h")
            # The caller already passed an include directory.
        else()
            file(GLOB _wx_root_candidates LIST_DIRECTORIES true
                "${source_root}/wxWidgets-*"
                "${source_root}/wxwidgets-*"
            )
            foreach(candidate IN LISTS _wx_root_candidates)
                if(EXISTS "${candidate}/include/wx/version.h")
                    set(stage_root "${candidate}/include")
                    break()
                endif()
            endforeach()
        endif()
    endif()

    if(label STREQUAL "wxWidgets" AND NOT EXISTS "${stage_root}/wx/version.h")
        message(FATAL_ERROR
            "wxWidgets headers were not found under ${source_root}. "
            "Check that the dependency populated correctly before packaging."
        )
    endif()

    set(headers)
    foreach(pattern IN LISTS header_patterns)
        file(GLOB_RECURSE matches LIST_DIRECTORIES false "${stage_root}/${pattern}")
        list(APPEND headers ${matches})
    endforeach()

    list(REMOVE_DUPLICATES headers)
    list(SORT headers)
    list(LENGTH headers header_count)
    message(STATUS "Header staging: ${label} -> ${header_count} files from ${stage_root}")

    if(header_count EQUAL 0)
        message(WARNING "Header staging: ${label} produced no files from ${stage_root}")
        return()
    endif()

    set(staged_count 0)
    foreach(header_file IN LISTS headers)
        file(RELATIVE_PATH rel_path "${stage_root}" "${header_file}")
        if(destination_prefix STREQUAL "")
            set(destination_path "${HEADER_STAGING_DIR}/${rel_path}")
        else()
            set(destination_path "${HEADER_STAGING_DIR}/${destination_prefix}/${rel_path}")
        endif()

        get_filename_component(destination_dir "${destination_path}" DIRECTORY)
        file(MAKE_DIRECTORY "${destination_dir}")
        configure_file("${header_file}" "${destination_path}" COPYONLY)

        math(EXPR staged_count "${staged_count} + 1")
        math(EXPR progress_mod "${staged_count} % 250")
        if(progress_mod EQUAL 0 OR staged_count EQUAL header_count)
            message(STATUS "Header staging: ${label} ${staged_count}/${header_count}")
        endif()
    endforeach()

    message(STATUS "Header staging complete: ${label} (${staged_count} files)")
endfunction()

message(STATUS "Starting header staging into ${HEADER_STAGING_DIR}")

wxbgi_stage_headers_from_root("${PROJECT_PUBLIC_ROOT}" "" "project")
if(WXBGI_ENABLE_WX AND DEFINED WXWIDGETS_SOURCE_ROOT AND NOT WXWIDGETS_SOURCE_ROOT STREQUAL "")
    wxbgi_stage_headers_from_root("${WXWIDGETS_SOURCE_ROOT}" "" "wxWidgets")
endif()
wxbgi_stage_headers_from_root("${GLEW_INCLUDE_ROOT}" "" "GLEW")
wxbgi_stage_headers_from_root("${GLFW_INCLUDE_ROOT}" "" "GLFW")
wxbgi_stage_headers_from_root("${GLM_INCLUDE_ROOT}" "" "GLM")
wxbgi_stage_headers_from_root("${MANIFOLD_INCLUDE_ROOT}" "" "MANIFOLD")
wxbgi_stage_headers_from_root("${NLOHMANN_JSON_INCLUDE_ROOT}" "" "NLOHMANN_JSON")
wxbgi_stage_headers_from_root("${YAML_CPP_INCLUDE_ROOT}" "" "YAML_CPP")
wxbgi_stage_headers_from_root("${STB_SOURCE_ROOT}" "stb" "STB")

message(STATUS "Header staging finished")