find_package(Python3 COMPONENTS Interpreter)

find_package(Doxygen QUIET)
find_package(LATEX COMPONENTS PDFLATEX QUIET)

if(DOXYGEN_FOUND)
    set(DOXYGEN_OUTPUT_DIR ${CMAKE_BINARY_DIR}/doxygen)
    set(DOXYGEN_CONFIG_FILE ${CMAKE_BINARY_DIR}/Doxyfile)
    set(DOXYGEN_PDF_CONFIG_FILE ${CMAKE_BINARY_DIR}/Doxyfile-pdf)

    set(DOXYGEN_GENERATE_LATEX NO)
    configure_file(
        ${CMAKE_SOURCE_DIR}/docs/Doxyfile.in
        ${DOXYGEN_CONFIG_FILE}
        @ONLY
    )

    set(DOXYGEN_GENERATE_LATEX YES)
    configure_file(
        ${CMAKE_SOURCE_DIR}/docs/Doxyfile.in
        ${DOXYGEN_PDF_CONFIG_FILE}
        @ONLY
    )

    add_custom_target(
        copy_doc_images
        COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_SOURCE_DIR}/docs/images
                ${DOXYGEN_OUTPUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${DOXYGEN_OUTPUT_DIR}/images
        COMMAND ${CMAKE_COMMAND} -E make_directory ${DOXYGEN_OUTPUT_DIR}/html/images
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/images
        COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_SOURCE_DIR}/docs/images
                ${DOXYGEN_OUTPUT_DIR}/images
        COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_SOURCE_DIR}/docs/images
                ${DOXYGEN_OUTPUT_DIR}/html/images
        COMMAND ${CMAKE_COMMAND} -E copy_directory
                ${CMAKE_SOURCE_DIR}/docs/images
                ${CMAKE_BINARY_DIR}/images
        COMMENT "Staging documentation images"
        VERBATIM
    )

    add_custom_target(
        api_docs
        COMMAND ${CMAKE_COMMAND} -E rm -rf ${DOXYGEN_OUTPUT_DIR}
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_CONFIG_FILE}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS copy_doc_images
        COMMENT "Generating Doxygen API documentation"
        VERBATIM
    )

    add_custom_command(
        OUTPUT ${DOXYGEN_OUTPUT_DIR}/latex/topics.tex
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                ${CMAKE_SOURCE_DIR}/docs/topics.tex
                ${DOXYGEN_OUTPUT_DIR}/latex/topics.tex
        DEPENDS ${CMAKE_SOURCE_DIR}/docs/topics.tex
    )

    add_custom_target(copy_topics_tex DEPENDS ${DOXYGEN_OUTPUT_DIR}/latex/topics.tex)

    if(PDFLATEX_COMPILER)
        if(WIN32)
            add_custom_target(
                api_docs_pdf
                COMMAND ${CMAKE_COMMAND} -E rm -rf ${DOXYGEN_OUTPUT_DIR}
                COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_PDF_CONFIG_FILE}
                COMMAND ${CMAKE_COMMAND} -E chdir ${DOXYGEN_OUTPUT_DIR}/latex make.bat
                DEPENDS copy_doc_images copy_topics_tex
                COMMENT "Generating Doxygen PDF documentation"
                VERBATIM
            )
        else()
            add_custom_target(
                api_docs_pdf
                COMMAND ${CMAKE_COMMAND} -E rm -rf ${DOXYGEN_OUTPUT_DIR}
                COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_PDF_CONFIG_FILE}
                COMMAND ${CMAKE_COMMAND} -E chdir ${DOXYGEN_OUTPUT_DIR}/latex ${CMAKE_MAKE_PROGRAM}
                DEPENDS copy_doc_images copy_topics_tex
                COMMENT "Generating Doxygen PDF documentation"
                VERBATIM
            )
        endif()
    else()
        add_custom_target(
            api_docs_pdf
            COMMAND ${CMAKE_COMMAND} -E echo "pdflatex not found. Install a LaTeX distribution (e.g., TeX Live/MiKTeX) and re-run CMake configure."
            COMMAND ${CMAKE_COMMAND} -E false
            COMMENT "LaTeX (pdflatex) is required for api_docs_pdf target"
            VERBATIM
        )
    endif()
else()
    add_custom_target(
        api_docs
        COMMAND ${CMAKE_COMMAND} -E echo "Doxygen not found. Install Doxygen and re-run CMake configure."
        COMMAND ${CMAKE_COMMAND} -E false
        COMMENT "Doxygen is required for api_docs target"
        VERBATIM
    )

    add_custom_target(
        api_docs_pdf
        COMMAND ${CMAKE_COMMAND} -E echo "Doxygen not found. Install Doxygen and re-run CMake configure."
        COMMAND ${CMAKE_COMMAND} -E false
        COMMENT "Doxygen is required for api_docs_pdf target"
        VERBATIM
    )
endif()

set(FPC_CANDIDATES)
if(WIN32)
    list(APPEND FPC_CANDIDATES ppcrossx64 ppcx64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64|ARM64")
    # Apple Silicon (M-series) and Linux aarch64: fpc wrapper or ppca64 native
    list(APPEND FPC_CANDIDATES fpc ppca64)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    list(APPEND FPC_CANDIDATES ppcx64 fpc)
else()
    list(APPEND FPC_CANDIDATES ppc386 fpc)
endif()

unset(FPC_COMPILER CACHE)
# Include Homebrew prefixes so CMake can locate FPC on macOS even when the
# shell PATH is not inherited by the cmake process (e.g. on Apple Silicon
# where Homebrew installs to /opt/homebrew or the user prefix).
find_program(FPC_COMPILER NAMES ${FPC_CANDIDATES}
    HINTS
        "$ENV{HOME}/homebrew/bin"
        /opt/homebrew/bin
        /usr/local/bin
)
if(FPC_COMPILER)
    message(STATUS "Found FreePascal compiler: ${FPC_COMPILER}")
else()
    message(STATUS "FreePascal compiler not found — Pascal targets skipped")
endif()

if(FPC_COMPILER)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bgidemo_pascal)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/keyboard_queue_pascal)

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/bgidemo_pascal/bgidemo${CMAKE_EXECUTABLE_SUFFIX}
        COMMAND ${FPC_COMPILER}
                -Fu${CMAKE_SOURCE_DIR}/examples/bgidemo-pascal
                -Fl$<TARGET_FILE_DIR:phoenix_gi>
                -FE${CMAKE_BINARY_DIR}/bgidemo_pascal
                -FU${CMAKE_BINARY_DIR}/bgidemo_pascal
                ${CMAKE_SOURCE_DIR}/examples/bgidemo-pascal/bgidemo.pas
        DEPENDS
            phoenix_gi
            ${CMAKE_SOURCE_DIR}/examples/bgidemo-pascal/bgidemo.pas
            ${CMAKE_SOURCE_DIR}/examples/bgidemo-pascal/Graph.pas
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        VERBATIM
    )

    add_custom_target(
        bgidemo_pascal_build
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:phoenix_gi>
                ${CMAKE_BINARY_DIR}/bgidemo_pascal
        DEPENDS
            phoenix_gi
            ${CMAKE_BINARY_DIR}/bgidemo_pascal/bgidemo${CMAKE_EXECUTABLE_SUFFIX}
    )

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/keyboard_queue_pascal/demo_wxbgi_keyboard_queue${CMAKE_EXECUTABLE_SUFFIX}
        COMMAND ${FPC_COMPILER}
                -Fu${CMAKE_SOURCE_DIR}/examples/demoFreePascal
                -Fl$<TARGET_FILE_DIR:phoenix_gi>
                -FE${CMAKE_BINARY_DIR}/keyboard_queue_pascal
                -FU${CMAKE_BINARY_DIR}/keyboard_queue_pascal
                ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_wxbgi_keyboard_queue.pas
        DEPENDS
            phoenix_gi
            ${CMAKE_SOURCE_DIR}/examples/demoFreePascal/demo_wxbgi_keyboard_queue.pas
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        VERBATIM
    )

    add_custom_target(
        wxbgi_keyboard_queue_pascal_build
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:phoenix_gi>
                ${CMAKE_BINARY_DIR}/keyboard_queue_pascal
        DEPENDS
            phoenix_gi
            ${CMAKE_BINARY_DIR}/keyboard_queue_pascal/demo_wxbgi_keyboard_queue${CMAKE_EXECUTABLE_SUFFIX}
    )
endif()
