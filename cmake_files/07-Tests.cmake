if(BUILD_TESTING)
    add_test(NAME bgi_api_coverage_cpp COMMAND $<TARGET_FILE:bgi_api_coverage_cpp>)
    set_tests_properties(bgi_api_coverage_cpp PROPERTIES TIMEOUT 20)
    add_test(NAME test_fonts COMMAND $<TARGET_FILE:test_fonts>)
    set_tests_properties(test_fonts PROPERTIES TIMEOUT 20)

    if(WXBGI_ENABLE_WX)
        add_test(NAME wx_bgi_solids_test COMMAND $<TARGET_FILE:wx_bgi_solids_test>)
        set_tests_properties(wx_bgi_solids_test PROPERTIES TIMEOUT 15)

        add_test(NAME wx_bgi_3d_orbit_test COMMAND $<TARGET_FILE:wx_bgi_3d_orbit_test>)
        set_tests_properties(wx_bgi_3d_orbit_test PROPERTIES TIMEOUT 60)

        add_test(NAME wx_bgi_canvas_coverage_test COMMAND $<TARGET_FILE:wx_bgi_canvas_coverage_test>)
        set_tests_properties(wx_bgi_canvas_coverage_test PROPERTIES TIMEOUT 30)

        add_test(NAME wxbgi_camera_demo_cpp COMMAND $<TARGET_FILE:wxbgi_camera_demo_cpp> --test)
        set_tests_properties(wxbgi_camera_demo_cpp PROPERTIES TIMEOUT 20)
        add_test(NAME test_field_vis COMMAND $<TARGET_FILE:test_field_vis>)
        set_tests_properties(test_field_vis PROPERTIES TIMEOUT 20)
        add_test(NAME wxbgi_openlb_live_demo COMMAND $<TARGET_FILE:wxbgi_openlb_live_demo> --test)
        set_tests_properties(wxbgi_openlb_live_demo PROPERTIES TIMEOUT 20)
        add_test(NAME wxbgi_openlb_material_preview_demo COMMAND $<TARGET_FILE:wxbgi_openlb_material_preview_demo> --test)
        set_tests_properties(wxbgi_openlb_material_preview_demo PROPERTIES TIMEOUT 20)
        if(WXBGI_ENABLE_OPENLB)
            add_test(NAME wxbgi_openlb_coupled_smoke COMMAND $<TARGET_FILE:wxbgi_openlb_coupled_smoke> --test)
            set_tests_properties(wxbgi_openlb_coupled_smoke PROPERTIES TIMEOUT 20)
            add_test(NAME wxbgi_openlb_pipe_3d_demo COMMAND $<TARGET_FILE:wxbgi_openlb_pipe_3d_demo> --test)
            set_tests_properties(wxbgi_openlb_pipe_3d_demo PROPERTIES TIMEOUT 150)
            add_test(NAME wxbgi_openlb_pipe_3d_wx_slider_demo COMMAND $<TARGET_FILE:wxbgi_openlb_pipe_3d_wx_slider_demo> --test)
            set_tests_properties(wxbgi_openlb_pipe_3d_wx_slider_demo PROPERTIES TIMEOUT 150)
        endif()
        add_test(NAME wxbgi_set_operations_demo_cpp COMMAND $<TARGET_FILE:wxbgi_set_operations_demo_cpp> --test)
        set_tests_properties(wxbgi_set_operations_demo_cpp PROPERTIES TIMEOUT 20)
        add_test(NAME wxbgi_affine_transform_demo_cpp COMMAND $<TARGET_FILE:wxbgi_affine_transform_demo_cpp> --test)
        set_tests_properties(wxbgi_affine_transform_demo_cpp PROPERTIES TIMEOUT 55)
    endif()

    add_test(NAME test_dds_serialize     COMMAND $<TARGET_FILE:test_dds_serialize>)
    set_tests_properties(test_dds_serialize     PROPERTIES TIMEOUT 20)

    add_test(NAME test_dds_deserialize   COMMAND $<TARGET_FILE:test_dds_deserialize>)
    set_tests_properties(test_dds_deserialize   PROPERTIES TIMEOUT 20)

    add_test(NAME test_dds_external_attrs COMMAND $<TARGET_FILE:test_dds_external_attrs>)
    set_tests_properties(test_dds_external_attrs PROPERTIES TIMEOUT 20)

    add_test(NAME test_openlb_bridge_materialize_2d COMMAND $<TARGET_FILE:test_openlb_bridge_materialize_2d>)
    set_tests_properties(test_openlb_bridge_materialize_2d PROPERTIES TIMEOUT 20)

    add_test(NAME test_dds_clear         COMMAND $<TARGET_FILE:test_dds_clear>)
    set_tests_properties(test_dds_clear         PROPERTIES TIMEOUT 20)

    add_test(NAME test_dds_cam2d_yz      COMMAND $<TARGET_FILE:test_dds_cam2d_yz>)
    set_tests_properties(test_dds_cam2d_yz      PROPERTIES TIMEOUT 20)

    add_test(NAME test_dds_cam3d_persp   COMMAND $<TARGET_FILE:test_dds_cam3d_persp>)
    set_tests_properties(test_dds_cam3d_persp   PROPERTIES TIMEOUT 20)

    add_test(NAME test_dds_csg           COMMAND $<TARGET_FILE:test_dds_csg>)
    set_tests_properties(test_dds_csg           PROPERTIES TIMEOUT 20)

    add_test(NAME test_multi_scene       COMMAND $<TARGET_FILE:test_multi_scene>)
    set_tests_properties(test_multi_scene       PROPERTIES TIMEOUT 20)

    add_test(NAME wxbgi_multi_scene_demo COMMAND $<TARGET_FILE:wxbgi_multi_scene_demo> --test)
    set_tests_properties(wxbgi_multi_scene_demo PROPERTIES TIMEOUT 20)

    add_test(NAME test_solids            COMMAND $<TARGET_FILE:test_solids>)
    set_tests_properties(test_solids            PROPERTIES TIMEOUT 30)

    if(WXBGI_ENABLE_TEST_SEAMS)
        add_test(NAME test_input_hooks   COMMAND $<TARGET_FILE:test_input_hooks>)
        set_tests_properties(test_input_hooks   PROPERTIES TIMEOUT 20)

        add_test(NAME test_input_bypass  COMMAND $<TARGET_FILE:test_input_bypass>)
        set_tests_properties(test_input_bypass  PROPERTIES TIMEOUT 20)
    endif()

    if(Python3_Interpreter_FOUND)
        add_test(
            NAME bgi_api_coverage_python
            COMMAND ${Python3_EXECUTABLE}
                    ${CMAKE_SOURCE_DIR}/examples/python/bgi_api_coverage.py
                    $<TARGET_FILE:wx_bgi_opengl>
        )
        set_tests_properties(bgi_api_coverage_python PROPERTIES TIMEOUT 20)
    endif()

    if(FPC_COMPILER)
        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_coverage)

        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/pascal_coverage/demo_bgi_api_coverage${CMAKE_EXECUTABLE_SUFFIX}
            COMMAND ${FPC_COMPILER}
                    -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                    -Fl$<TARGET_FILE_DIR:wx_bgi_opengl>
                    -FE${CMAKE_BINARY_DIR}/pascal_coverage
                    -FU${CMAKE_BINARY_DIR}/pascal_coverage
                    ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_api_coverage.pas
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_api_coverage.pas
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            VERBATIM
        )

        add_custom_target(
            bgi_api_coverage_pascal_build
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/pascal_coverage
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_BINARY_DIR}/pascal_coverage/demo_bgi_api_coverage${CMAKE_EXECUTABLE_SUFFIX}
        )

        add_test(
            NAME bgi_api_coverage_pascal_build
            COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config $<CONFIG> --target bgi_api_coverage_pascal_build
        )
        set_tests_properties(bgi_api_coverage_pascal_build PROPERTIES TIMEOUT 120)

        if(UNIX AND NOT APPLE)
            add_test(
                NAME bgi_api_coverage_pascal_run
                COMMAND ${CMAKE_COMMAND} -E env
                        "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/pascal_coverage:$<TARGET_FILE_DIR:wx_bgi_opengl>:$ENV{LD_LIBRARY_PATH}"
                        ${CMAKE_BINARY_DIR}/pascal_coverage/demo_bgi_api_coverage${CMAKE_EXECUTABLE_SUFFIX}
            )
        else()
            add_test(
                NAME bgi_api_coverage_pascal_run
                COMMAND ${CMAKE_BINARY_DIR}/pascal_coverage/demo_bgi_api_coverage${CMAKE_EXECUTABLE_SUFFIX}
            )
        endif()
        set_tests_properties(
            bgi_api_coverage_pascal_run
            PROPERTIES
            DEPENDS bgi_api_coverage_pascal_build
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_coverage
            TIMEOUT 20
        )

        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_canvas_coverage)

        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/pascal_canvas_coverage/demo_bgi_canvas_coverage${CMAKE_EXECUTABLE_SUFFIX}
            COMMAND ${FPC_COMPILER}
                    -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                    -Fl$<TARGET_FILE_DIR:wx_bgi_opengl>
                    -FE${CMAKE_BINARY_DIR}/pascal_canvas_coverage
                    -FU${CMAKE_BINARY_DIR}/pascal_canvas_coverage
                    ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_canvas_coverage.pas
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_canvas_coverage.pas
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            VERBATIM
        )

        add_custom_target(
            bgi_canvas_coverage_pascal_build
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/pascal_canvas_coverage
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_BINARY_DIR}/pascal_canvas_coverage/demo_bgi_canvas_coverage${CMAKE_EXECUTABLE_SUFFIX}
        )

        add_test(
            NAME bgi_canvas_coverage_pascal_build
            COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config $<CONFIG> --target bgi_canvas_coverage_pascal_build
        )
        set_tests_properties(bgi_canvas_coverage_pascal_build PROPERTIES TIMEOUT 120)

        if(UNIX AND NOT APPLE)
            add_test(
                NAME bgi_canvas_coverage_pascal_run
                COMMAND ${CMAKE_COMMAND} -E env
                        "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/pascal_canvas_coverage:$<TARGET_FILE_DIR:wx_bgi_opengl>:$ENV{LD_LIBRARY_PATH}"
                        ${CMAKE_BINARY_DIR}/pascal_canvas_coverage/demo_bgi_canvas_coverage${CMAKE_EXECUTABLE_SUFFIX}
            )
        else()
            add_test(
                NAME bgi_canvas_coverage_pascal_run
                COMMAND ${CMAKE_BINARY_DIR}/pascal_canvas_coverage/demo_bgi_canvas_coverage${CMAKE_EXECUTABLE_SUFFIX}
            )
        endif()
        set_tests_properties(
            bgi_canvas_coverage_pascal_run
            PROPERTIES
            DEPENDS bgi_canvas_coverage_pascal_build
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_canvas_coverage
            TIMEOUT 20
        )

        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_input_hooks)

        set(WXBGI_FPC_SEAMS_FLAG "")
        if(WXBGI_ENABLE_TEST_SEAMS)
            set(WXBGI_FPC_SEAMS_FLAG "-dWXBGI_ENABLE_TEST_SEAMS")
        endif()

        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_hooks${CMAKE_EXECUTABLE_SUFFIX}
            COMMAND ${FPC_COMPILER}
                    ${WXBGI_FPC_SEAMS_FLAG}
                    -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                    -Fl$<TARGET_FILE_DIR:wx_bgi_opengl>
                    -FE${CMAKE_BINARY_DIR}/pascal_input_hooks
                    -FU${CMAKE_BINARY_DIR}/pascal_input_hooks
                    ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/test_input_hooks.pas
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/test_input_hooks.pas
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            VERBATIM
        )

        add_custom_target(
            test_input_hooks_pascal_build
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/pascal_input_hooks
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_hooks${CMAKE_EXECUTABLE_SUFFIX}
        )

        add_test(
            NAME test_input_hooks_pascal_build
            COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config $<CONFIG>
                    --target test_input_hooks_pascal_build
        )
        set_tests_properties(test_input_hooks_pascal_build PROPERTIES TIMEOUT 120)

        if(UNIX AND NOT APPLE)
            add_test(
                NAME test_input_hooks_pascal_run
                COMMAND ${CMAKE_COMMAND} -E env
                        "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/pascal_input_hooks:$<TARGET_FILE_DIR:wx_bgi_opengl>:$ENV{LD_LIBRARY_PATH}"
                        ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_hooks${CMAKE_EXECUTABLE_SUFFIX}
            )
        else()
            add_test(
                NAME test_input_hooks_pascal_run
                COMMAND ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_hooks${CMAKE_EXECUTABLE_SUFFIX}
            )
        endif()
        set_tests_properties(
            test_input_hooks_pascal_run
            PROPERTIES
            DEPENDS test_input_hooks_pascal_build
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_input_hooks
            TIMEOUT 20
        )

        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/pascal_input_hooks/demo_input_hooks${CMAKE_EXECUTABLE_SUFFIX}
            COMMAND ${FPC_COMPILER}
                    -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                    -Fl$<TARGET_FILE_DIR:wx_bgi_opengl>
                    -FE${CMAKE_BINARY_DIR}/pascal_input_hooks
                    -FU${CMAKE_BINARY_DIR}/pascal_input_hooks
                    ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_input_hooks.pas
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_input_hooks.pas
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            VERBATIM
        )

        add_custom_target(
            demo_input_hooks_pascal_build
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/pascal_input_hooks
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_BINARY_DIR}/pascal_input_hooks/demo_input_hooks${CMAKE_EXECUTABLE_SUFFIX}
        )

        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_bypass${CMAKE_EXECUTABLE_SUFFIX}
            COMMAND ${FPC_COMPILER}
                    ${WXBGI_FPC_SEAMS_FLAG}
                    -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                    -Fl$<TARGET_FILE_DIR:wx_bgi_opengl>
                    -FE${CMAKE_BINARY_DIR}/pascal_input_hooks
                    -FU${CMAKE_BINARY_DIR}/pascal_input_hooks
                    ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/test_input_bypass.pas
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/test_input_bypass.pas
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            VERBATIM
        )

        add_custom_target(
            test_input_bypass_pascal_build
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/pascal_input_hooks
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_bypass${CMAKE_EXECUTABLE_SUFFIX}
        )

        add_test(
            NAME test_input_bypass_pascal_build
            COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --config $<CONFIG>
                    --target test_input_bypass_pascal_build
        )
        set_tests_properties(test_input_bypass_pascal_build PROPERTIES TIMEOUT 120)

        if(UNIX AND NOT APPLE)
            add_test(
                NAME test_input_bypass_pascal_run
                COMMAND ${CMAKE_COMMAND} -E env
                        "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/pascal_input_hooks:$<TARGET_FILE_DIR:wx_bgi_opengl>:$ENV{LD_LIBRARY_PATH}"
                        ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_bypass${CMAKE_EXECUTABLE_SUFFIX}
            )
        else()
            add_test(
                NAME test_input_bypass_pascal_run
                COMMAND ${CMAKE_BINARY_DIR}/pascal_input_hooks/test_input_bypass${CMAKE_EXECUTABLE_SUFFIX}
            )
        endif()
        set_tests_properties(
            test_input_bypass_pascal_run
            PROPERTIES
            DEPENDS test_input_bypass_pascal_build
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_input_hooks
            TIMEOUT 20
        )

        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/pascal_demos)

        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/pascal_demos/demo_bgi_wrapper${CMAKE_EXECUTABLE_SUFFIX}
            COMMAND ${FPC_COMPILER}
                    -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                    -Fl$<TARGET_FILE_DIR:wx_bgi_opengl>
                    -FE${CMAKE_BINARY_DIR}/pascal_demos
                    -FU${CMAKE_BINARY_DIR}/pascal_demos
                    ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_wrapper.pas
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_wrapper.pas
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            VERBATIM
        )

        add_custom_target(
            demo_bgi_wrapper_pascal_build
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/pascal_demos
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_BINARY_DIR}/pascal_demos/demo_bgi_wrapper${CMAKE_EXECUTABLE_SUFFIX}
        )

        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/pascal_demos/demo_bgi_wrapper_gui${CMAKE_EXECUTABLE_SUFFIX}
            COMMAND ${FPC_COMPILER}
                    -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                    -Fl$<TARGET_FILE_DIR:wx_bgi_opengl>
                    -FE${CMAKE_BINARY_DIR}/pascal_demos
                    -FU${CMAKE_BINARY_DIR}/pascal_demos
                    ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_wrapper_gui.pas
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_bgi_wrapper_gui.pas
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            VERBATIM
        )

        add_custom_target(
            demo_bgi_wrapper_gui_pascal_build
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/pascal_demos
            DEPENDS
                wx_bgi_opengl
                ${CMAKE_BINARY_DIR}/pascal_demos/demo_bgi_wrapper_gui${CMAKE_EXECUTABLE_SUFFIX}
        )
    endif()
endif()
