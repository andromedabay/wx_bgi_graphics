include(cmake_files/05-zz01-Helpers.cmake)

add_executable(bgi_api_coverage_cpp examples/cpp/bgi_api_coverage.cpp)
target_link_libraries(bgi_api_coverage_cpp PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(bgi_api_coverage_cpp)

add_executable(wxbgi_keyboard_queue_cpp examples/cpp/wxbgi_keyboard_queue.cpp)
target_link_libraries(wxbgi_keyboard_queue_cpp PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(wxbgi_keyboard_queue_cpp)

add_executable(wxbgi_fonts_demo_cpp examples/cpp/wxbgi_fonts_demo.cpp)
target_link_libraries(wxbgi_fonts_demo_cpp PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(wxbgi_fonts_demo_cpp)

add_executable(test_fonts examples/cpp/test_fonts.cpp)
target_link_libraries(test_fonts PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_fonts)

if(WXBGI_ENABLE_WX)
    add_executable(test_field_vis examples/cpp/test_field_vis.cpp)
    target_link_libraries(test_field_vis PRIVATE wx_bgi_opengl)
    wxbgi_copy_runtime(test_field_vis)

    add_executable(wxbgi_openlb_live_demo examples/cpp/wxbgi_openlb_live_demo.cpp)
    target_link_libraries(wxbgi_openlb_live_demo PRIVATE wx_bgi_opengl)
    wxbgi_copy_runtime(wxbgi_openlb_live_demo)

    add_executable(wxbgi_openlb_material_preview_demo examples/cpp/wxbgi_openlb_material_preview_demo.cpp)
    target_link_libraries(wxbgi_openlb_material_preview_demo PRIVATE wx_bgi_opengl)
    wxbgi_copy_runtime(wxbgi_openlb_material_preview_demo)

    if(WXBGI_ENABLE_OPENLB)
        set(OPENLB_VERSION_STRING "")
        execute_process(
            COMMAND git -C "${OPENLB_ROOT}" describe --always --dirty --tags
            OUTPUT_VARIABLE OPENLB_VERSION_STRING
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(OPENLB_VERSION_STRING STREQUAL "")
            get_filename_component(OPENLB_VERSION_STRING "${OPENLB_ROOT}" NAME)
        endif()

        find_package(Threads REQUIRED)
        find_package(ZLIB REQUIRED)

        add_library(openlb_support STATIC
            ${OPENLB_ROOT}/src/core/expr.cpp
            ${OPENLB_ROOT}/src/core/olbInit.cpp
            ${OPENLB_ROOT}/src/io/ostreamManager.cpp
            ${OPENLB_ROOT}/src/communication/mpiManager.cpp
            ${OPENLB_ROOT}/external/tinyxml2/tinyxml2.cpp
        )
        target_include_directories(openlb_support PUBLIC
            ${OPENLB_ROOT}/src
            ${OPENLB_ROOT}/external/tinyxml
            ${OPENLB_ROOT}/external/tinyxml2
        )
        target_compile_definitions(openlb_support PUBLIC
            PLATFORM_CPU_SISD=1
            OLB_VERSION="${OPENLB_VERSION_STRING}"
        )
        target_link_libraries(openlb_support PUBLIC ZLIB::ZLIB Threads::Threads)
        if(MSVC)
            target_compile_options(openlb_support PUBLIC
                /Zc:__cplusplus
                /FI"${CMAKE_SOURCE_DIR}/src/openlb_msvc_compat.h"
            )
        endif()

        add_executable(wxbgi_openlb_coupled_smoke examples/cpp/wxbgi_openlb_coupled_smoke.cpp)
        target_link_libraries(wxbgi_openlb_coupled_smoke PRIVATE wx_bgi_opengl openlb_support)
        wxbgi_copy_runtime(wxbgi_openlb_coupled_smoke)

        add_executable(wxbgi_openlb_pipe_3d_demo examples/cpp/openlb-demo/wxbgi_openlb_pipe_3d_demo.cpp)
        target_link_libraries(wxbgi_openlb_pipe_3d_demo PRIVATE wx_bgi_opengl openlb_support)
        wxbgi_copy_runtime(wxbgi_openlb_pipe_3d_demo)

        add_executable(wxbgi_openlb_pipe_3d_wx_slider_demo examples/cpp/openlb-demo/wxbgi_openlb_pipe_3d_wx_slider_demo.cpp)
        target_link_libraries(wxbgi_openlb_pipe_3d_wx_slider_demo PRIVATE wx_bgi_wx openlb_support)
        wxbgi_copy_runtime(wxbgi_openlb_pipe_3d_wx_slider_demo)
    endif()
endif()

# Screenshot capture utility ---------------------------------------------------

add_executable(capture_screenshots tools/capture_screenshots.cpp)
target_link_libraries(capture_screenshots PRIVATE wx_bgi_opengl glfw)
wxbgi_copy_runtime(capture_screenshots)

# Phase E tests ---------------------------------------------------------------

add_executable(test_dds_serialize examples/cpp/test_dds_serialize.cpp)
target_link_libraries(test_dds_serialize PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_dds_serialize)

add_executable(test_dds_deserialize examples/cpp/test_dds_deserialize.cpp)
target_link_libraries(test_dds_deserialize PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_dds_deserialize)

add_executable(test_dds_external_attrs examples/cpp/test_dds_external_attrs.cpp)
target_link_libraries(test_dds_external_attrs PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_dds_external_attrs)

add_executable(test_openlb_bridge_materialize_2d examples/cpp/test_openlb_bridge_materialize_2d.cpp)
target_link_libraries(test_openlb_bridge_materialize_2d PRIVATE wx_bgi_opengl glm)
wxbgi_copy_runtime(test_openlb_bridge_materialize_2d)

add_executable(test_dds_clear examples/cpp/test_dds_clear.cpp)
target_link_libraries(test_dds_clear PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_dds_clear)

add_executable(test_dds_cam2d_yz examples/cpp/test_dds_cam2d_yz.cpp)
target_link_libraries(test_dds_cam2d_yz PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_dds_cam2d_yz)

add_executable(test_dds_cam3d_persp examples/cpp/test_dds_cam3d_persp.cpp)
target_link_libraries(test_dds_cam3d_persp PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_dds_cam3d_persp)

add_executable(test_dds_csg examples/cpp/test_dds_csg.cpp)
target_link_libraries(test_dds_csg PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_dds_csg)

add_executable(test_multi_scene examples/cpp/test_multi_scene.cpp)
target_link_libraries(test_multi_scene PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_multi_scene)

add_executable(wxbgi_multi_scene_demo examples/cpp/wxbgi_multi_scene_demo.cpp)
target_link_libraries(wxbgi_multi_scene_demo PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(wxbgi_multi_scene_demo)

add_executable(test_solids examples/cpp/test_solids.cpp)
target_link_libraries(test_solids PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(test_solids)

# Input hook automated test (Phase 2 requires WXBGI_ENABLE_TEST_SEAMS)
if(WXBGI_ENABLE_TEST_SEAMS)
    add_executable(test_input_hooks examples/cpp/test_input_hooks.cpp)
    target_link_libraries(test_input_hooks PRIVATE wx_bgi_opengl)
    target_compile_definitions(test_input_hooks PRIVATE WXBGI_ENABLE_TEST_SEAMS=1)
    wxbgi_copy_runtime(test_input_hooks)
endif()

# Input hook interactive demo
add_executable(wxbgi_input_hooks_cpp examples/cpp/wxbgi_input_hooks.cpp)
target_link_libraries(wxbgi_input_hooks_cpp PRIVATE wx_bgi_opengl)
wxbgi_copy_runtime(wxbgi_input_hooks_cpp)

# Scroll + bypass + hk_dds automated test (requires WXBGI_ENABLE_TEST_SEAMS)
if(WXBGI_ENABLE_TEST_SEAMS)
    add_executable(test_input_bypass examples/cpp/test_input_bypass.cpp)
    target_link_libraries(test_input_bypass PRIVATE wx_bgi_opengl)
    target_compile_definitions(test_input_bypass PRIVATE WXBGI_ENABLE_TEST_SEAMS=1)
    wxbgi_copy_runtime(test_input_bypass)
endif()

if(WXBGI_ENABLE_WX)
    add_executable(wx_bgi_solids_test examples/wx/wx_bgi_solids_test.cpp)
    target_link_libraries(wx_bgi_solids_test PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wx_bgi_solids_test)

    if(WIN32)
        add_executable(wx_bgi_3d_orbit_test WIN32
            examples/wx/wx_bgi_3d_orbit_test.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wx_bgi_3d_orbit_test MACOSX_BUNDLE
            examples/wx/wx_bgi_3d_orbit_test.cpp)
        set_target_properties(wx_bgi_3d_orbit_test PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wx_bgi_3d_orbit_test examples/wx/wx_bgi_3d_orbit_test.cpp)
    endif()
    target_link_libraries(wx_bgi_3d_orbit_test PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wx_bgi_3d_orbit_test)

    if(WIN32)
        add_executable(wx_bgi_canvas_coverage_test WIN32
            examples/wx/wx_bgi_canvas_coverage_test.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wx_bgi_canvas_coverage_test MACOSX_BUNDLE
            examples/wx/wx_bgi_canvas_coverage_test.cpp)
        set_target_properties(wx_bgi_canvas_coverage_test PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wx_bgi_canvas_coverage_test
            examples/wx/wx_bgi_canvas_coverage_test.cpp)
    endif()
    target_link_libraries(wx_bgi_canvas_coverage_test PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wx_bgi_canvas_coverage_test)

    if(WIN32)
        add_executable(wx_bgi_app WIN32
            examples/wx/wx_bgi_app.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wx_bgi_app MACOSX_BUNDLE examples/wx/wx_bgi_app.cpp)
        set_target_properties(wx_bgi_app PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wx_bgi_app examples/wx/wx_bgi_app.cpp)
    endif()
    target_link_libraries(wx_bgi_app PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wx_bgi_app)

    if(WIN32)
        add_executable(wx_bgi_3d_app WIN32
            examples/wx/wx_bgi_3d_app.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wx_bgi_3d_app MACOSX_BUNDLE examples/wx/wx_bgi_3d_app.cpp)
        set_target_properties(wx_bgi_3d_app PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wx_bgi_3d_app examples/wx/wx_bgi_3d_app.cpp)
    endif()
    target_link_libraries(wx_bgi_3d_app PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wx_bgi_3d_app)

    if(WIN32)
        add_executable(wx_multi_scene_demo WIN32
            examples/wx/wx_multi_scene_demo.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wx_multi_scene_demo MACOSX_BUNDLE
            examples/wx/wx_multi_scene_demo.cpp)
        set_target_properties(wx_multi_scene_demo PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wx_multi_scene_demo examples/wx/wx_multi_scene_demo.cpp)
    endif()
    target_link_libraries(wx_multi_scene_demo PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wx_multi_scene_demo)

    if(WIN32)
        add_executable(wxbgi_camera_demo_cpp WIN32
            examples/cpp/wxbgi_camera_demo.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wxbgi_camera_demo_cpp MACOSX_BUNDLE
            examples/cpp/wxbgi_camera_demo.cpp)
        set_target_properties(wxbgi_camera_demo_cpp PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wxbgi_camera_demo_cpp examples/cpp/wxbgi_camera_demo.cpp)
    endif()
    target_link_libraries(wxbgi_camera_demo_cpp PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wxbgi_camera_demo_cpp)

    if(WIN32)
        add_executable(wxbgi_set_operations_demo_cpp WIN32
            examples/cpp/wxbgi_set_operations_demo.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wxbgi_set_operations_demo_cpp MACOSX_BUNDLE
            examples/cpp/wxbgi_set_operations_demo.cpp)
        set_target_properties(wxbgi_set_operations_demo_cpp PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wxbgi_set_operations_demo_cpp examples/cpp/wxbgi_set_operations_demo.cpp)
    endif()
    target_link_libraries(wxbgi_set_operations_demo_cpp PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wxbgi_set_operations_demo_cpp)

    if(WIN32)
        add_executable(wxbgi_affine_transform_demo_cpp WIN32
            examples/cpp/wxbgi_affine_transform_demo.cpp
            main.exe.manifest
            resources.rc
        )
    elseif(APPLE)
        add_executable(wxbgi_affine_transform_demo_cpp MACOSX_BUNDLE
            examples/cpp/wxbgi_affine_transform_demo.cpp)
        set_target_properties(wxbgi_affine_transform_demo_cpp PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/Info.plist)
    else()
        add_executable(wxbgi_affine_transform_demo_cpp examples/cpp/wxbgi_affine_transform_demo.cpp)
    endif()
    target_link_libraries(wxbgi_affine_transform_demo_cpp PRIVATE wx_bgi_wx)
    wxbgi_copy_runtime(wxbgi_affine_transform_demo_cpp)

    if(WXBGI_ENABLE_OPENLB)
        add_custom_target(openlb_bridge_package
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/openlb_bridge
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/openlb_bridge/openlb-demo
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_FILE:wx_bgi_opengl>
                    ${CMAKE_BINARY_DIR}/openlb_bridge
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    ${CMAKE_SOURCE_DIR}/src/wx_bgi.h
                    ${CMAKE_SOURCE_DIR}/src/wx_bgi_ext.h
                    ${CMAKE_SOURCE_DIR}/src/wx_bgi_openlb.h
                    ${CMAKE_SOURCE_DIR}/examples/cpp/wxbgi_openlb_live_demo.cpp
                    ${CMAKE_SOURCE_DIR}/examples/cpp/wxbgi_openlb_material_preview_demo.cpp
                    ${CMAKE_SOURCE_DIR}/examples/cpp/wxbgi_openlb_coupled_smoke.cpp
                    ${CMAKE_BINARY_DIR}/openlb_bridge
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                    ${CMAKE_SOURCE_DIR}/examples/cpp/openlb-demo/wxbgi_openlb_pipe_3d_demo.cpp
                    ${CMAKE_SOURCE_DIR}/examples/cpp/openlb-demo/wxbgi_openlb_pipe_3d_wx_slider_demo.cpp
                    ${CMAKE_SOURCE_DIR}/examples/cpp/openlb-demo/run_openlb_pipe_3d_demo.sh
                    ${CMAKE_SOURCE_DIR}/examples/cpp/openlb-demo/run_openlb_pipe_3d_demo_macos.sh
                    ${CMAKE_SOURCE_DIR}/examples/cpp/openlb-demo/run_openlb_pipe_3d_wx_slider_demo.sh
                    ${CMAKE_SOURCE_DIR}/examples/cpp/openlb-demo/run_openlb_pipe_3d_wx_slider_demo_macos.sh
                    ${CMAKE_BINARY_DIR}/openlb_bridge/openlb-demo
            DEPENDS wx_bgi_opengl wxbgi_openlb_live_demo wxbgi_openlb_pipe_3d_demo wxbgi_openlb_pipe_3d_wx_slider_demo
            COMMENT "Staging wx_bgi OpenLB bridge assets in ${CMAKE_BINARY_DIR}/openlb_bridge"
        )
    endif()
endif()
