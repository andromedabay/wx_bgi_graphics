function(wxbgi_copy_runtime target_name)
    add_custom_command(
        TARGET ${target_name} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:wx_bgi_opengl>
                $<TARGET_FILE_DIR:${target_name}>
    )
endfunction()
