cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(zstd VERSION 1.4.5 LANGUAGES C)

set(URL "https://github.com/facebook/zstd/archive/v${PROJECT_VERSION}.tar.gz")
set(SHA "734d1f565c42f691f8420c8d06783ad818060fc390dee43ae0a89f86d0a4f8c2")
download_source(${URL} ${SHA} src configure.patch)

# Headers
set(headers
  src/lib/zstd.h
  src/lib/common/zstd_errors.h)

# Sources
file(GLOB sources
  src/lib/common/*.h
  src/lib/common/*.c
  src/lib/compress/*.h
  src/lib/compress/*.c
  src/lib/decompress/*.h
  src/lib/decompress/*.c
  src/lib/dictBuilder/*.h
  src/lib/dictBuilder/*.c)

# Library
add_library(zstd ${headers} ${sources})
target_include_directories(zstd BEFORE PUBLIC src/lib src/lib/common)
target_compile_definitions(zstd PRIVATE ZSTD_MULTITHREAD ZSTD_HEAPMODE=0)

if(WIN32 AND BUILD_SHARED_LIBS)
  target_compile_definitions(zstd PRIVATE ZSTD_DLL_EXPORT=1)
endif()

if(MSVC)
  target_compile_options(zstd PRIVATE /wd5105)
endif()

# Install
install(TARGETS zstd)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:zstd> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
