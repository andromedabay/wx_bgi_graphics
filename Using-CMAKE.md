# Using CMake with wx_bgi_graphics

This project is configured to be built as a shared graphics library with a self-contained OpenGL stack and optional wxWidgets support. The CMake setup is intended for end users who want to build the library, consume its public headers, and generate Doxygen documentation without editing the source code.

## Build modes

### 1) Default configuration

This is the normal release-oriented build.

```bash
cmake -S . -B build
cmake --build build
# OR - to Use 6 parallel cores to compile:
cmake --build build -j6
```

Default behavior:

- `WXBGI_BUILD_SHARED=ON`
- `WXBGI_ENABLE_WX=ON`
- OpenGL/GLEW/GLFW/GLM and the other dependency stack are fetched and built as part of the project
- The library target is generated as a shared library named `wx_bgi_graphics`
- Public headers are available from the project source tree and can be staged for packaging

### 2) Build a static library instead of a shared library

```bash
cmake -S . -B build-static -DWXBGI_BUILD_SHARED=OFF
cmake --build build-static
```

This toggles the main library target to a static library while leaving the rest of the build behavior intact.

### 3) Disable wxWidgets and use the GLFW-only path

```bash
cmake -S . -B build-no-wx -DWXBGI_ENABLE_WX=OFF
cmake --build build-no-wx
```

This disables the wxWidgets backend and forces the GLFW fallback backend used by the library.

### 4) Use system-installed GLFW instead of fetching it

```bash
cmake -S . -B build-system-glfw -DWXBGI_SYSTEM_GLFW=ON
cmake --build build-system-glfw
```

This uses `find_package(glfw3)` instead of the project-managed FetchContent dependency.

### 5) Use system-installed wxWidgets instead of fetching it

```bash
cmake -S . -B build-system-wx -DWXBGI_ENABLE_WX=ON -DWXBGI_SYSTEM_WX=ON
cmake --build build-system-wx
```

This is useful in CI or on developer machines where wxWidgets is already installed.

## Build/install workflow

### Install the library and headers

```bash
cmake -S . -B build-install
cmake --build build-install
cmake --install build-install --prefix /path/to/install/root
```

The install tree contains:

- the shared or static library in the library directory
- public headers in the include directory under the project namespace
- CMake export metadata for downstream project integration

### Enable or disable header installation

```bash
cmake -S . -B build-no-install-headers -DWXBGI_INSTALL_HEADERS=OFF
```

This skips installing the public headers.

### Enable or disable docs installation

```bash
cmake -S . -B build-no-install-docs -DWXBGI_INSTALL_DOCS=OFF
```

This skips installation of generated documentation to the install tree.

## Doxygen documentation

Documentation is generated through Doxygen whenever it is available.

### Generate HTML docs

```bash
cmake -S . -B build-docs
cmake --build build-docs --target api_docs
```

Output location:

```text
build-docs/doxygen/html/
```

### Generate PDF docs

```bash
cmake -S . -B build-pdf-docs
cmake --build build-pdf-docs --target api_docs_pdf
```

This requires:

- Doxygen
- LaTeX / `pdflatex`

If LaTeX is not installed, the PDF target will emit a clear message and fail gracefully.

## Clean generated folders

An opt-in clean target is available to remove generated build directories and downloaded third-party install artifacts while leaving the repository placeholders in place.

```bash
cmake -S . -B build-clean -DWXBGI_ENABLE_CLEAN_TARGET=ON
cmake --build build-clean --target clean-all
```

This removes directories matching `build*` under the project root, except the current build tree being used to run the clean target, and removes everything under `third_party/installed` except `.gitignore`.

## Packaging release artifacts

An artifact staging target is also provided to package the library, headers, and documentation into a release-friendly directory.

```bash
cmake -S . -B build-release
cmake --build build-release --target wx_bgi_headers_package
```

This populates an output tree under:

```text
build-release/artifacts/
```

Typical contents include:

- `bin/` for runtime outputs
- `lib/` for the built library
- `headers_staging/` for the staged public headers
- `docs/` for generated documentation

## Useful option summary

- `WXBGI_BUILD_SHARED=ON` — build the main library as a shared library
- `WXBGI_INSTALL_HEADERS=ON` — install public headers
- `WXBGI_INSTALL_DOCS=ON` — install Doxygen output with the install tree
- `WXBGI_ENABLE_WX=ON` — enable the wxWidgets backend (default)
- `WXBGI_ENABLE_GLFW=OFF` — disable the GLFW fallback when wxWidgets is on
- `WXBGI_SYSTEM_GLFW=OFF` — fetch GLFW from source instead of using the system package
- `WXBGI_SYSTEM_WX=OFF` — fetch wxWidgets from source instead of using system packages
- `WXBGI_ENABLE_OPENLB=OFF` — disable optional OpenLB bridge support
- `WXBGI_ENABLE_CLEAN_TARGET=OFF` — keep the clean-all target disabled unless you explicitly want a project-wide cleanup step
- `WXBGI_ENABLE_TEST_SEAMS=OFF` — keep test seams disabled for public release binaries

## Notes

- This project intentionally keeps the library source unchanged; all release configuration, dependency selection, and doc generation are driven from CMake.
- The default behavior is release-friendly and ready for downstream linking to the shared library output.
- The library name used by the build is `wx_bgi_graphics`.
