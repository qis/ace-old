cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(bzip2 VERSION 1.0.8 LANGUAGES C)

set(URL "https://sourceware.org/pub/bzip2/bzip2-${PROJECT_VERSION}.tar.gz")
set(SHA "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269")
download_source(${URL} ${SHA} src configure.patch)

# Headers
set(headers
  src/bzlib.h)

# Sources
set(sources
  src/blocksort.c
  src/huffman.c
  src/crctable.c
  src/randtable.c
  src/compress.c
  src/decompress.c
  src/bzlib.c
  src/bzlib_private.h)

# Library
add_library(bzip2 ${headers} ${sources})
target_include_directories(bzip2 BEFORE PUBLIC src)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(bzip2 PRIVATE BZ_BUILD)
endif()

if(MSVC)
  target_compile_options(bzip2 PRIVATE /wd4244 /wd4267 /wd5105)
else()
  target_compile_options(bzip2 PRIVATE -Wno-implicit-fallthrough)
endif()

if(WIN32)
  target_compile_definitions(bzip2 PRIVATE
    _CRT_NONSTDC_NO_DEPRECATE
    _CRT_SECURE_NO_DEPRECATE)
else()
  target_compile_definitions(bzip2 PRIVATE
    BZ_STRICT_ANSI)
endif()

# Install
install(TARGETS bzip2)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:bzip2> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
