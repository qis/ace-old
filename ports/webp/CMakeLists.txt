cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(webp VERSION 1.1.0 LANGUAGES C)

set(URL "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${PROJECT_VERSION}.tar.gz")
set(SHA "98a052268cc4d5ece27f76572a7f50293f439c17a98e67c4ea0c7ed6f50ef043")
download_source(${URL} ${SHA} src configure.patch)

# Options
option(WEBP_NEAR_LOSSLESS "Enable near-lossless encoding" ON)
option(WEBP_ENABLE_SWAP_16BIT_CSP "Enable byte swap for 16 bit colorspaces." OFF)

# Checks
include(CheckCSourceCompiles)
check_c_source_compiles("
    int main(void) {
      (void)__builtin_bswap16(0);
      return 0;
    }
  " HAVE_BUILTIN_BSWAP16)
check_c_source_compiles("
    int main(void) {
      (void)__builtin_bswap32(0);
      return 0;
    }
  " HAVE_BUILTIN_BSWAP32)
check_c_source_compiles("
    int main(void) {
      (void)__builtin_bswap64(0);
      return 0;
    }
  " HAVE_BUILTIN_BSWAP64)
check_c_source_compiles("
    #include <math.h>
    int main(int argc, char** argv) {
      return (int)pow(argc, 2.5);
    }
  " HAVE_MATH_LIBRARY)

include(CheckIncludeFiles)
check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)
check_include_files(dlfcn.h HAVE_DLFCN_H)
check_include_files(inttypes.h HAVE_INTTYPES_H)
check_include_files(memory.h HAVE_MEMORY_H)
check_include_files(shlwapi.h HAVE_SHLWAPI_H)
check_include_files(stdint.h HAVE_STDINT_H)
check_include_files(stdlib.h HAVE_STDLIB_H)
check_include_files(strings.h HAVE_STRINGS_H)
check_include_files(string.h HAVE_STRING_H)
check_include_files(sys/stat.h HAVE_SYS_STAT_H)
check_include_files(sys/types.h HAVE_SYS_TYPES_H)
check_include_files(unistd.h HAVE_UNISTD_H)
check_include_files(wincodec.h HAVE_WINCODEC_H)
check_include_files(windows.h HAVE_WINDOWS_H)

set(PACKAGE "webp")
set(PACKAGE_BUGREPORT "https://bugs.chromium.org/p/webp")
set(PACKAGE_NAME "webp")
set(PACKAGE_STRING "webp ${PROJECT_VERSION}")
set(PACKAGE_TARNAME "webp")
set(PACKAGE_URL "http://developers.google.com/speed/webp")
set(PACKAGE_VERSION "${PROJECT_VERSION}")
set(VERSION "${PROJECT_VERSION}")

# Settings
set(WEBP_HAVE_JPEG ON)
set(WEBP_HAVE_PNG ON)
set(WEBP_HAVE_SSE2 ON)
set(WEBP_HAVE_SSE41 ON)
set(WEBP_USE_THREAD ON)
set(WEBP_ENABLE_SIMD ON)

# Configs
configure_file(src/cmake/config.h.in
  ${CMAKE_INSTALL_PREFIX}/lib/include/src/webp/config.h)

# Headers
file(GLOB headers src/src/webp/*.h)

# Sources
set(sources
  ${CMAKE_INSTALL_PREFIX}/lib/include/src/webp/config.h)

function(parse_makefile_am FOLDER SRC_REGEX)
  file(READ ${FOLDER}/Makefile.am MAKEFILE_AM)
  string(REGEX MATCHALL
    "${SRC_REGEX}_SOURCES[ ]*\\+?=[ ]+[0-9a-z\\._ ]*"
    FILES_PER_LINE ${MAKEFILE_AM})
  set(SRCS ${sources})
  foreach(FILES ${FILES_PER_LINE})
    string(FIND ${FILES} "=" OFFSET)
    math(EXPR OFFSET "${OFFSET} + 2")
    string(SUBSTRING ${FILES} ${OFFSET} -1 FILES)
    if(FILES)
      string(REGEX MATCHALL "[0-9a-z\\._]+" FILES ${FILES})
      foreach(FILE ${FILES})
        list(APPEND SRCS ${FOLDER}/${FILE})
      endforeach()
    endif()
  endforeach()
  set(sources ${SRCS} PARENT_SCOPE)
endfunction()

set(WEBP_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/src)
parse_makefile_am(${WEBP_SRC_DIR}/dec "")
parse_makefile_am(${WEBP_SRC_DIR}/dsp "COMMON")
parse_makefile_am(${WEBP_SRC_DIR}/dsp "decode_[^ ]*")
parse_makefile_am(${WEBP_SRC_DIR}/dsp "ENC")
parse_makefile_am(${WEBP_SRC_DIR}/dsp "dsp_[^ ]*")
parse_makefile_am(${WEBP_SRC_DIR}/enc "")
parse_makefile_am(${WEBP_SRC_DIR}/utils "COMMON")
parse_makefile_am(${WEBP_SRC_DIR}/utils "decode_[^ ]*")
parse_makefile_am(${WEBP_SRC_DIR}/utils "ENC")
parse_makefile_am(${WEBP_SRC_DIR}/demux "")
parse_makefile_am(${WEBP_SRC_DIR}/mux "")

# Library
add_library(webp ${headers} ${sources})
target_include_directories(webp PRIVATE src)
target_compile_definitions(webp PRIVATE HAVE_CONFIG_H)
target_link_libraries(webp PRIVATE ace::jpeg ace::png)

if(WEBP_ENABLE_SWAP_16BIT_CSP)
  target_compile_definitions(webp PRIVATE WEBP_SWAP_16BIT_CSP=1)
endif()

if(WIN32)
  target_link_libraries(webp PRIVATE shlwapi windowscodecs)
else()
  target_link_libraries(webp PRIVATE m)
endif()

if(WIN32 AND BUILD_SHARED_LIBS)
  target_compile_definitions(webp PRIVATE WEBP_EXPORT)
endif()

if(MSVC)
  target_compile_options(webp PRIVATE /wd5105)
else()
  target_compile_options(webp PRIVATE -Wno-pedantic -Wno-maybe-uninitialized)
endif()

# Install
install(TARGETS webp)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:webp> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include/webp)
endif()
