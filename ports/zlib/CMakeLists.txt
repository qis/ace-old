cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(zlib VERSION 1.2.11 LANGUAGES C)

set(URL "https://www.zlib.net/zlib-${PROJECT_VERSION}.tar.gz")
set(SHA "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1")
download_source(${URL} ${SHA} src configure.patch)

# Headers
set(headers
  src/zconf.h
  src/zlib.h)

# Sources
set(sources
  src/crc32.h
  src/deflate.h
  src/gzguts.h
  src/inffast.h
  src/inffixed.h
  src/inflate.h
  src/inftrees.h
  src/trees.h
  src/zutil.h
  src/adler32.c
  src/crc32.c
  src/deflate.c
  src/inflate.c
  src/infback.c
  src/inftrees.c
  src/inffast.c
  src/trees.c
  src/uncompr.c
  src/zutil.c)

# Library
add_library(zlib ${headers} ${sources})
target_include_directories(zlib PRIVATE src)

if(WIN32)
  target_compile_definitions(zlib PRIVATE _CRT_SECURE_NO_DEPRECATE _CRT_NONSTDC_NO_DEPRECATE)
endif()

if(MSVC)
  target_compile_options(zlib PRIVATE /wd4267)
else()
  target_compile_options(zlib PRIVATE -Wno-implicit-fallthrough -Wno-multistatement-macros)
endif()

# Install
install(TARGETS zlib)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:zlib> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
