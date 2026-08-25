function(wxbgi_copy_runtime target_name)
    if(WIN32 AND WXBGI_ENABLE_WX)
        target_sources(${target_name} PRIVATE
            ${CMAKE_SOURCE_DIR}/main.exe.manifest
            ${CMAKE_SOURCE_DIR}/resources.rc
        )
    endif()

    add_custom_command(
        TARGET ${target_name} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:wx_bgi_graphics>
                $<TARGET_FILE_DIR:${target_name}>
    )
endfunction()
