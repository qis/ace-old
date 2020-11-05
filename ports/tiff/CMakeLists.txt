cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(tiff VERSION 4.1.0 LANGUAGES C CXX)

set(URL "http://download.osgeo.org/libtiff/tiff-${PROJECT_VERSION}.tar.gz")
set(SHA "5d29f32517dadb6dbcd1255ea5bbc93a2b54b94fbf83653b4d65c7d6775b8634")
download_source(${URL} ${SHA} src configure.patch)

# Algorithms
option(CCITT_SUPPORT "CCITT Group 3 & 4 algorithms" ON)
option(PACKBITS_SUPPORT "Macintosh PackBits algorithm" ON)
option(LZW_SUPPORT "LZW algorithm" ON)
option(THUNDER_SUPPORT "ThunderScan 4-bit RLE algorithm" ON)
option(NEXT_SUPPORT "NeXT 2-bit RLE algorithm" ON)
option(LOGLUV_SUPPORT "LogLuv high dynamic range algorithm" ON)
option(MDI_SUPPORT "Microsoft Document Imaging" ON)
option(PIXARLOG_SUPPORT "Pixar log-format algorithm (requires zlib)" ON)

# Features
option(STRIPCHOP_DEFAULT "Strip chopping" ON)
option(DEFER_STRILE_LOAD "Deferred strip/tile offset/size loading" OFF)
option(DEFAULT_EXTRASAMPLE_AS_ALPHA "Treat a fourth sample with no EXTRASAMPLE_ value as being ASSOCALPHA." ON)
option(CHECK_JPEG_YCBCR_SUBSAMPLING "Pick up YCbCr subsampling info from the JPEG data stream" ON)

# Settings
set(JPEG_SUPPORT ON)
set(WEBP_SUPPORT ON)
set(LZMA_SUPPORT ON)
set(ZLIB_SUPPORT ${PIXARLOG_SUPPORT})
set(ZSTD_SUPPORT ON)
set(SUBIFD_SUPPORT ON)

if(STRIPCHOP_DEFAULT)
  set(STRIP_SIZE_DEFAULT 8192 CACHE STRING "Default size of the strip in bytes")
endif()

if(UNIX)
  set(FILE_OFFSET_BITS 64)
endif()

# Checks
include(TestBigEndian)
test_big_endian(HOST_BIG_ENDIAN)

include(CheckIncludeFile)
check_include_file("assert.h" HAVE_ASSERT_H)
check_include_file("dlfcn.h" HAVE_DLFCN_H)
check_include_file("fcntl.h" HAVE_FCNTL_H)
check_include_file("inttypes.h" HAVE_INTTYPES_H)
check_include_file("search.h" HAVE_SEARCH_H)
check_include_file("stdint.h" HAVE_STDINT_H)
check_include_file("string.h" HAVE_STRING_H)
check_include_file("strings.h" HAVE_STRINGS_H)
check_include_file("sys/time.h" HAVE_SYS_TIME_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_include_file("unistd.h" HAVE_UNISTD_H)
check_include_file("io.h" HAVE_IO_H)

include(CheckSymbolExists)
check_symbol_exists(mmap "sys/mman.h" HAVE_MMAP)
check_symbol_exists(setmode "unistd.h" HAVE_SETMODE)
check_symbol_exists(snprintf "stdio.h" HAVE_SNPRINTF)
check_symbol_exists(strcasecmp "strings.h" HAVE_STRCASECMP)
check_symbol_exists(strtol "stdlib.h" HAVE_STRTOL)
check_symbol_exists(strtoll "stdlib.h" HAVE_STRTOLL)
check_symbol_exists(strtoul "stdlib.h" HAVE_STRTOUL)
check_symbol_exists(strtoull "stdlib.h" HAVE_STRTOULL)
check_symbol_exists(getopt "unistd.h;stdio.h" HAVE_GETOPT)
check_symbol_exists(lfind "search.h" HAVE_LFIND)

include(CheckCSourceCompiles)
check_c_source_compiles("
#include <sys/time.h>
#include <time.h>
int main() {
  return 0;
}" TIME_WITH_SYS_TIME)

check_c_source_compiles("
#include <sys/types.h>
#include <time.h>
int main() {
  struct tm tm;
  int *p = &tm.tm_sec;
  return !p;
}" TM_IN_SYS_TIME)

set(INLINE_KEYWORD "inline")

include(CheckTypeSize)
set(CMAKE_EXTRA_INCLUDE_FILES "stddef.h")
check_type_size("signed int" SIZEOF_SIGNED_INT)
check_type_size("unsigned int" SIZEOF_UNSIGNED_INT)
check_type_size("signed long" SIZEOF_SIGNED_LONG)
check_type_size("unsigned long" SIZEOF_UNSIGNED_LONG)
check_type_size("signed long long" SIZEOF_SIGNED_LONG_LONG)
check_type_size("unsigned long long" SIZEOF_UNSIGNED_LONG_LONG)
check_type_size("unsigned char *" SIZEOF_UNSIGNED_CHAR_P)
check_type_size("ptrdiff_t" SIZEOF_PTRDIFF_T)
check_type_size("size_t" SIZEOF_SIZE_T)

set(TIFF_INT8_T "signed char")
set(TIFF_UINT8_T "unsigned char")

set(TIFF_INT16_T "signed short")
set(TIFF_UINT16_T "unsigned short")

if(SIZEOF_SIGNED_INT EQUAL 4)
  set(TIFF_INT32_T "signed int")
  set(TIFF_INT32_FORMAT "%d")
elseif(SIZEOF_SIGNED_LONG EQUAL 4)
  set(TIFF_INT32_T "signed long")
  set(TIFF_INT32_FORMAT "%ld")
endif()

if(SIZEOF_UNSIGNED_INT EQUAL 4)
  set(TIFF_UINT32_T "unsigned int")
  set(TIFF_UINT32_FORMAT "%u")
elseif(SIZEOF_UNSIGNED_LONG EQUAL 4)
  set(TIFF_UINT32_T "unsigned long")
  set(TIFF_UINT32_FORMAT "%lu")
endif()

if(SIZEOF_SIGNED_LONG EQUAL 8)
  set(TIFF_INT64_T "signed long")
  set(TIFF_INT64_FORMAT "%ld")
elseif(SIZEOF_SIGNED_LONG_LONG EQUAL 8)
  set(TIFF_INT64_T "signed long long")
  set(TIFF_INT64_FORMAT "%lld")
endif()

if(SIZEOF_UNSIGNED_LONG EQUAL 8)
  set(TIFF_UINT64_T "unsigned long")
  set(TIFF_UINT64_FORMAT "%lu")
elseif(SIZEOF_UNSIGNED_LONG_LONG EQUAL 8)
  set(TIFF_UINT64_T "unsigned long long")
  set(TIFF_UINT64_FORMAT "%llu")
endif()

if(SIZEOF_UNSIGNED_INT EQUAL SIZEOF_SIZE_T)
  set(TIFF_SIZE_T "unsigned int")
  set(TIFF_SIZE_FORMAT "%u")
  set(TIFF_SSIZE_T "signed int")
  set(TIFF_SSIZE_FORMAT "%d")
elseif(SIZEOF_UNSIGNED_LONG EQUAL SIZEOF_SIZE_T)
  set(TIFF_SIZE_T "unsigned long")
  set(TIFF_SIZE_FORMAT "%lu")
  set(TIFF_SSIZE_T "signed long")
  set(TIFF_SSIZE_FORMAT "%ld")
elseif(SIZEOF_UNSIGNED_LONG_LONG EQUAL SIZEOF_SIZE_T)
  set(TIFF_SIZE_T "unsigned long long")
  set(TIFF_SIZE_FORMAT "%llu")
  set(TIFF_SSIZE_T "signed long long")
  set(TIFF_SSIZE_FORMAT "%lld")
endif()

if(NOT SIZEOF_PTRDIFF_T)
  set(TIFF_PTRDIFF_T "${TIFF_SSIZE_T}")
  set(TIFF_PTRDIFF_FORMAT "${SSIZE_FORMAT}")
else()
  set(TIFF_PTRDIFF_T "ptrdiff_t")
  set(TIFF_PTRDIFF_FORMAT "%ld")
endif()

set(HOST_FILLORDER "FILLORDER_LSB2MSB")
set(HAVE_IEEEFP 1)

# Configs
configure_file(src/libtiff/tiffconf.h.cmake.in
  ${CMAKE_INSTALL_PREFIX}/include/tiffconf.h @ONLY)

configure_file(src/libtiff/tif_config.h.cmake.in
  ${CMAKE_INSTALL_PREFIX}/lib/include/tif_config.h @ONLY)

# Headers
set(headers
  src/libtiff/tiff.h
  src/libtiff/tiffio.h
  src/libtiff/tiffio.hxx
  src/libtiff/tiffvers.h)

# Sources
set(sources
  src/libtiff/t4.h
  src/libtiff/tif_dir.h
  src/libtiff/tif_predict.h
  src/libtiff/tiffiop.h
  src/libtiff/uvcode.h
  src/libtiff/tif_aux.c
  src/libtiff/tif_close.c
  src/libtiff/tif_codec.c
  src/libtiff/tif_color.c
  src/libtiff/tif_compress.c
  src/libtiff/tif_dir.c
  src/libtiff/tif_dirinfo.c
  src/libtiff/tif_dirread.c
  src/libtiff/tif_dirwrite.c
  src/libtiff/tif_dumpmode.c
  src/libtiff/tif_error.c
  src/libtiff/tif_extension.c
  src/libtiff/tif_fax3.c
  src/libtiff/tif_fax3sm.c
  src/libtiff/tif_flush.c
  src/libtiff/tif_getimage.c
  src/libtiff/tif_jbig.c
  src/libtiff/tif_jpeg.c
  src/libtiff/tif_jpeg_12.c
  src/libtiff/tif_luv.c
  src/libtiff/tif_lzma.c
  src/libtiff/tif_lzw.c
  src/libtiff/tif_next.c
  src/libtiff/tif_ojpeg.c
  src/libtiff/tif_open.c
  src/libtiff/tif_packbits.c
  src/libtiff/tif_pixarlog.c
  src/libtiff/tif_predict.c
  src/libtiff/tif_print.c
  src/libtiff/tif_read.c
  src/libtiff/tif_strip.c
  src/libtiff/tif_swab.c
  src/libtiff/tif_stream.cxx
  src/libtiff/tif_thunder.c
  src/libtiff/tif_tile.c
  src/libtiff/tif_unix.c
  src/libtiff/tif_version.c
  src/libtiff/tif_warning.c
  src/libtiff/tif_webp.c
  src/libtiff/tif_write.c
  src/libtiff/tif_zip.c
  src/libtiff/tif_zstd.c
  ${CMAKE_INSTALL_PREFIX}/include/tiffconf.h
  ${CMAKE_INSTALL_PREFIX}/lib/include/tif_config.h)

# Library
add_library(tiff ${headers} ${sources})
target_include_directories(tiff PRIVATE src/libtiff)

target_link_libraries(tiff PRIVATE ace::jpeg ace::webp ace::lzma ace::zstd)

if(ZLIB_SUPPORT)
  target_link_libraries(tiff PRIVATE ace::zlib)
endif()

if(WIN32 AND BUILD_SHARED_LIBS)
  target_compile_definitions(tiff PRIVATE TIFF_EXPORT)
  target_sources(tiff PRIVATE src/libtiff/libtiff.def)
endif()

if(MSVC)
  target_compile_options(tiff PRIVATE /wd4005 /wd4244 /wd4996 /wd5105)
else()
  target_compile_options(tiff PRIVATE -Wno-format -Wno-unused-but-set-variable)
endif()

# Install
install(TARGETS tiff)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:tiff> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
