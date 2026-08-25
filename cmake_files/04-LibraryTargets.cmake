# Build a static GLEW library from fetched sources to keep the build self-contained.
add_library(glew_static STATIC ${glew_SOURCE_DIR}/src/glew.c)
add_library(GLEW::GLEW ALIAS glew_static)

set_target_properties(glew_static PROPERTIES POSITION_INDEPENDENT_CODE ON)

target_include_directories(glew_static
    PUBLIC
        ${glew_SOURCE_DIR}/include
)

target_compile_definitions(glew_static
    PUBLIC
        GLEW_STATIC
)

target_link_libraries(glew_static
    PUBLIC
        OpenGL::GL
)

if(UNIX AND NOT APPLE)
    target_link_libraries(glew_static PUBLIC ${CMAKE_DL_LIBS})
endif()

set(SRCS
    src/bgi_state.cpp
    src/bgi_draw.cpp
    src/bgi_font.cpp
    src/bgi_outline_font.cpp
    src/bgi_image.cpp
    src/bgi_api.cpp
    src/bgi_modern_api.cpp
    src/bgi_camera.cpp
    src/bgi_camera_api.cpp
    src/bgi_ucs.cpp
    src/bgi_ucs_api.cpp
    src/bgi_world_api.cpp
    src/bgi_dds.cpp
    src/bgi_dds_api.cpp
    src/bgi_dds_scene_api.cpp
    src/bgi_dds_serial.cpp
    src/bgi_dds_render.cpp
    src/bgi_openlb_bridge.cpp
    src/bgi_openlb_bridge_api.cpp
    src/bgi_solid_api.cpp
    src/bgi_solid_render.cpp
    src/bgi_export.cpp
    src/bgi_gl.cpp
    src/bgi_overlay.cpp
    src/bgi_overlay_api.cpp
    src/bgi_field_vis.cpp
)

set(GENERATED_FONT_DIR ${CMAKE_BINARY_DIR}/generated_fonts)
set(ROBOTO_FONT_CPP ${GENERATED_FONT_DIR}/roboto_font.cpp)
set(PLAYFAIR_FONT_CPP ${GENERATED_FONT_DIR}/playfair_font.cpp)
set(HANDJET_FONT_CPP ${GENERATED_FONT_DIR}/handjet_font.cpp)

add_custom_command(
    OUTPUT ${ROBOTO_FONT_CPP}
    COMMAND ${Python3_EXECUTABLE}
            ${CMAKE_SOURCE_DIR}/tools/embed_binary.py
            ${CMAKE_SOURCE_DIR}/third_party/fonts/roboto/Roboto.ttf
            ${ROBOTO_FONT_CPP}
            kRobotoFont
    DEPENDS
        ${CMAKE_SOURCE_DIR}/tools/embed_binary.py
        ${CMAKE_SOURCE_DIR}/third_party/fonts/roboto/Roboto.ttf
)

add_custom_command(
    OUTPUT ${PLAYFAIR_FONT_CPP}
    COMMAND ${Python3_EXECUTABLE}
            ${CMAKE_SOURCE_DIR}/tools/embed_binary.py
            ${CMAKE_SOURCE_DIR}/third_party/fonts/playfairdisplay/PlayfairDisplay.ttf
            ${PLAYFAIR_FONT_CPP}
            kPlayfairDisplayFont
    DEPENDS
        ${CMAKE_SOURCE_DIR}/tools/embed_binary.py
        ${CMAKE_SOURCE_DIR}/third_party/fonts/playfairdisplay/PlayfairDisplay.ttf
)

add_custom_command(
    OUTPUT ${HANDJET_FONT_CPP}
    COMMAND ${Python3_EXECUTABLE}
            ${CMAKE_SOURCE_DIR}/tools/embed_binary.py
            ${CMAKE_SOURCE_DIR}/third_party/fonts/handjet/Handjet.ttf
            ${HANDJET_FONT_CPP}
            kHandjetFont
    DEPENDS
        ${CMAKE_SOURCE_DIR}/tools/embed_binary.py
        ${CMAKE_SOURCE_DIR}/third_party/fonts/handjet/Handjet.ttf
)

list(APPEND SRCS
    ${ROBOTO_FONT_CPP}
    ${PLAYFAIR_FONT_CPP}
    ${HANDJET_FONT_CPP}
)

if(WXBGI_ENABLE_WX)
    list(APPEND SRCS
        src/wx_bgi/wx_bgi_canvas.cpp
        src/wx_bgi/bgi_wx_standalone.cpp
    )
endif()

set(WXBGI_LIB_TARGET wx_bgi_graphics)

if(WXBGI_BUILD_SHARED)
    add_library(${WXBGI_LIB_TARGET} SHARED ${SRCS})
else()
    add_library(${WXBGI_LIB_TARGET} STATIC ${SRCS})
endif()

#add_library(wx_bgi_opengl ALIAS ${WXBGI_LIB_TARGET})

set_target_properties(${WXBGI_LIB_TARGET} PROPERTIES
    OUTPUT_NAME "wx_bgi_graphics"
    EXPORT_NAME "wx_bgi_graphics"
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
)

target_include_directories(${WXBGI_LIB_TARGET} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/wx_bgi_graphics>
)

target_include_directories(${WXBGI_LIB_TARGET} PRIVATE ${FETCHCONTENT_BASE_DIR}/include_external)
target_compile_definitions(${WXBGI_LIB_TARGET} PRIVATE GLEW_STATIC)
target_include_directories(${WXBGI_LIB_TARGET} PRIVATE
    ${EP_BASE_YAML_CPP}/include
    ${EP_BASE_MANIFOLD}/include
    ${EP_BASE_GLM}/glm
    ${EP_BASE_NLOHMANN_JSON}/include
    ${nlohmann_json_SOURCE_DIR}/include
    ${EP_BASE_STB}
)

# Propagate core link dependencies to consumers so targets that link
# against `wx_bgi_graphics` automatically get the required libraries.
target_link_libraries(${WXBGI_LIB_TARGET} PUBLIC GLEW::GLEW glfw OpenGL::GL glm::glm nlohmann_json::nlohmann_json yaml-cpp manifold)

if(WXBGI_ENABLE_WX)
    # Keep wxWidgets usage requirements visible to consumers, especially when
    # wx_bgi_graphics is built as a static library.
    target_link_libraries(${WXBGI_LIB_TARGET} PUBLIC wx_bgi_wx_iface)
    target_include_directories(${WXBGI_LIB_TARGET} PRIVATE
        ${CMAKE_SOURCE_DIR}/src/wx
        ${glew_SOURCE_DIR}/include)
    target_compile_definitions(${WXBGI_LIB_TARGET} PRIVATE WXBGI_ENABLE_WX)
endif()

if(WXBGI_ENABLE_TEST_SEAMS)
    # Expose compile-time guard to both the library and consumers of the public
    # header so declarations/definitions stay in sync during test builds.
    target_compile_definitions(${WXBGI_LIB_TARGET} PUBLIC WXBGI_ENABLE_TEST_SEAMS=1)
endif()

if(UNIX AND NOT APPLE)
    target_link_libraries(${WXBGI_LIB_TARGET} PRIVATE ${CMAKE_DL_LIBS} pthread)
endif()

if(WIN32)
    set_target_properties(${WXBGI_LIB_TARGET} PROPERTIES PREFIX "")
endif()

if(WXBGI_ENABLE_WX)
    add_library(wx_bgi_wx STATIC src/wx_bgi/wx_bgi_canvas.cpp)
    target_include_directories(wx_bgi_wx
        PUBLIC ${CMAKE_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/src
               ${glew_SOURCE_DIR}/include)
    target_compile_definitions(wx_bgi_wx PUBLIC WXBGI_ENABLE_WX GLEW_STATIC)
    target_link_libraries(wx_bgi_wx PUBLIC ${WXBGI_LIB_TARGET} GLEW::GLEW wx_bgi_wx_iface)
    set_target_properties(wx_bgi_wx PROPERTIES
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

if(WXBGI_INSTALL_HEADERS)
    install(TARGETS ${WXBGI_LIB_TARGET}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/wx_bgi_graphics
    )

    install(
        DIRECTORY ${CMAKE_SOURCE_DIR}/src/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/wx_bgi_graphics
        FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.hh"
    )

    if(WXBGI_ENABLE_WX AND DEFINED wxwidgets_SOURCE_DIR)
        install(
            DIRECTORY ${wxwidgets_SOURCE_DIR}/include/
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/wx_bgi_graphics/wxWidgets
            FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.hh"
        )
    endif()
endif()
