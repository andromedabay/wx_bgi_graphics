if(NOT DEFINED SOURCE_DIR OR SOURCE_DIR STREQUAL "")
    message(FATAL_ERROR "SOURCE_DIR is required")
endif()

if(NOT DEFINED DEST_DIR OR DEST_DIR STREQUAL "")
    message(FATAL_ERROR "DEST_DIR is required")
endif()

if(NOT EXISTS "${SOURCE_DIR}")
    message(FATAL_ERROR "Source directory does not exist: ${SOURCE_DIR}")
endif()

file(MAKE_DIRECTORY "${DEST_DIR}")

# Copy only top-level file entries and skip nested directories.
file(GLOB _wx_bgi_top_level_files LIST_DIRECTORIES false "${SOURCE_DIR}/*")
foreach(_wx_bgi_file IN LISTS _wx_bgi_top_level_files)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${_wx_bgi_file}" "${DEST_DIR}"
        RESULT_VARIABLE _wx_bgi_copy_result
    )
    if(NOT _wx_bgi_copy_result EQUAL 0)
        message(FATAL_ERROR "Failed to copy file '${_wx_bgi_file}' to '${DEST_DIR}'")
    endif()
endforeach()
