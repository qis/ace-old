cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(jpeg VERSION 2.0.5 LANGUAGES C ASM_NASM)

set(URL "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${PROJECT_VERSION}.tar.gz")
set(SHA "b3090cd37b5a8b3e4dbd30a1311b3989a894e5d3c668f14cbc6739d77c9402b7")
download_source(${URL} ${SHA} src)

# Settings
set(BITS_IN_JSAMPLE 8)                  # jconfig.h.in | win/jconfig.h.in
set(WITH_SIMD 1)                        # jconfig.h.in | win/jconfig.h.in
set(C_ARITH_CODING_SUPPORTED 1)         # jconfig.h.in | win/jconfig.h.in
set(D_ARITH_CODING_SUPPORTED 1)         # jconfig.h.in | win/jconfig.h.in
set(MEM_SRCDST_SUPPORTED 1)             # jconfig.h.in | win/jconfig.h.in
set(JPEG_LIB_VERSION 80)                # jconfig.h.in | win/jconfig.h.in

string(TIMESTAMP BUILD "%Y%m%d")        # jconfigint.h.in
set(VERSION ${CMAKE_PROJECT_VERSION})   # jconfigint.h.in | jconfig.h.in | win/jconfig.h.in

set(MAJOR ${PROJECT_VERSION_MAJOR})
set(MINOR ${PROJECT_VERSION_MINOR})
set(PATCH ${PROJECT_VERSION_PATCH})
function(pad_number NUMBER OUTPUT_LEN)
  string(LENGTH "${${NUMBER}}" INPUT_LEN)
  if(INPUT_LEN LESS OUTPUT_LEN)
    math(EXPR ZEROES "${OUTPUT_LEN} - ${INPUT_LEN} - 1")
    set(NUM ${${NUMBER}})
    foreach(C RANGE ${ZEROES})
      set(NUM "0${NUM}")
    endforeach()
    set(${NUMBER} ${NUM} PARENT_SCOPE)
  endif()
endfunction()
pad_number(MINOR 3)
pad_number(PATCH 3)
set(LIBJPEG_TURBO_VERSION_NUMBER ${MAJOR}${MINOR}${PATCH})  # jconfig.h.in | win/jconfig.h.in

# Checks
include(CheckTypeSize)
include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)

check_type_size("size_t" SIZE_T)  # jconfigint.h.in
check_type_size("unsigned long" UNSIGNED_LONG)

if(UNIX)
  check_include_files("locale.h" HAVE_LOCALE_H)         # jconfig.h.in
  check_include_files("stddef.h" HAVE_STDDEF_H)         # jconfig.h.in
  check_include_files("stdlib.h" HAVE_STDLIB_H)         # jconfig.h.in
  check_include_files("sys/types.h" NEED_SYS_TYPES_H)   # jconfig.h.in

  check_symbol_exists(memset "string.h" HAVE_MEMSET)
  check_symbol_exists(memcpy "string.h" HAVE_MEMCPY)
  if(NOT HAVE_MEMSET AND NOT HAVE_MEMCPY)
    set(NEED_BSD_STRINGS 1)     # jconfig.h.in
  endif()

  check_c_source_runs("
  #include <stdio.h>
  #include <stdlib.h>
  int is_shifting_signed(long arg) {
    long res = arg >> 4;
    if (res == -0x7F7E80CL) {
      return 1;  // right shift is signed
    }
    // See if unsigned-shift hack will fix it.
    // We can't just test exact value since it depends on width of long...
    res |= (~0L) << (32-4);
    if (res == -0x7F7E80CL) {
      return 0;  // right shift is unsigned
    }
    printf(\"Right shift isn't acting as I expect it to.\\\\n\");
    printf(\"I fear the JPEG software will not work at all.\\\\n\\\\n\");
    return 0;  // try it with unsigned anyway
  }
  int main() {
    exit(is_shifting_signed(-0x7F7E80B1L));
  }" RIGHT_SHIFT_IS_UNSIGNED)   # jconfig.h.in

  set(HAVE_UNSIGNED_CHAR 1)     # jconfig.h.in
  set(HAVE_UNSIGNED_SHORT 1)    # jconfig.h.in
endif()

if(MSVC)
  set(INLINE "__forceinline")   # jconfigint.h.in
else()
  set(INLINE "inline __attribute__((always_inline))")  # jconfigint.h.in
endif()

if(MSVC)
  set(THREAD_LOCAL "__declspec(thread)")  # jconfigint.h.in
else()
  set(THREAD_LOCAL "__thread")  # jconfigint.h.in
endif()

if(SIZE_T EQUAL UNSIGNED_LONG)
  check_c_source_compiles("
  int main(int argc, char *argv[]) {
    unsigned long a = argc;
    return __builtin_ctzl(a);
  }" HAVE_BUILTIN_CTZL)         # jconfigint.h.in
endif()

if(MSVC)
  check_include_files("intrin.h" HAVE_INTRIN_H)  # jconfigint.h.in
endif()

# Configs
if(WIN32)
  configure_file(src/win/jconfig.h.in
    ${CMAKE_INSTALL_PREFIX}/include/jconfig.h)
else()
  configure_file(src/jconfig.h.in
    ${CMAKE_INSTALL_PREFIX}/include/jconfig.h)
endif()

configure_file(src/jconfigint.h.in
  ${CMAKE_INSTALL_PREFIX}/lib/include/jconfigint.h)

# Headers
set(headers
  ${CMAKE_CURRENT_SOURCE_DIR}/src/turbojpeg.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/jpeglib.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/jmorecfg.h
  ${CMAKE_CURRENT_SOURCE_DIR}/src/jerror.h)

# Sources
set(sources
  # JPEG
  src/jcapimin.c
  src/jcapistd.c
  src/jccoefct.c
  src/jccolor.c
  src/jcdctmgr.c
  src/jchuff.c
  src/jcicc.c
  src/jcinit.c
  src/jcmainct.c
  src/jcmarker.c
  src/jcmaster.c
  src/jcomapi.c
  src/jcparam.c
  src/jcphuff.c
  src/jcprepct.c
  src/jcsample.c
  src/jctrans.c
  src/jdapimin.c
  src/jdapistd.c
  src/jdatadst.c
  src/jdatasrc.c
  src/jdcoefct.c
  src/jdcolor.c
  src/jddctmgr.c
  src/jdhuff.c
  src/jdicc.c
  src/jdinput.c
  src/jdmainct.c
  src/jdmarker.c
  src/jdmaster.c
  src/jdmerge.c
  src/jdphuff.c
  src/jdpostct.c
  src/jdsample.c
  src/jdtrans.c
  src/jerror.c
  src/jfdctflt.c
  src/jfdctfst.c
  src/jfdctint.c
  src/jidctflt.c
  src/jidctfst.c
  src/jidctint.c
  src/jidctred.c
  src/jquant1.c
  src/jquant2.c
  src/jutils.c
  src/jmemmgr.c
  src/jmemnobs.c

  # Arithmetic encoding/decoding support when emulating the libjpeg v6b API/ABI
  src/jaricom.c

  # Arithmetic encoding support when emulating the libjpeg v6b API/ABI
  src/jcarith.c

  # Arithmetic decoding support when emulating the libjpeg v6b API/ABI
  src/jdarith.c

  # TURBOJPEG
  src/turbojpeg.c
  src/transupp.c
  src/jdatadst-tj.c
  src/jdatasrc-tj.c
  src/rdbmp.c
  src/rdppm.c
  src/wrbmp.c
  src/wrppm.c

  # SIMD
  src/simd/x86_64/jsimdcpu.asm
  src/simd/x86_64/jfdctflt-sse.asm
  src/simd/x86_64/jccolor-sse2.asm
  src/simd/x86_64/jcgray-sse2.asm
  src/simd/x86_64/jchuff-sse2.asm
  src/simd/x86_64/jcphuff-sse2.asm
  src/simd/x86_64/jcsample-sse2.asm
  src/simd/x86_64/jdcolor-sse2.asm
  src/simd/x86_64/jdmerge-sse2.asm
  src/simd/x86_64/jdsample-sse2.asm
  src/simd/x86_64/jfdctfst-sse2.asm
  src/simd/x86_64/jfdctint-sse2.asm
  src/simd/x86_64/jidctflt-sse2.asm
  src/simd/x86_64/jidctfst-sse2.asm
  src/simd/x86_64/jidctint-sse2.asm
  src/simd/x86_64/jidctred-sse2.asm
  src/simd/x86_64/jquantf-sse2.asm
  src/simd/x86_64/jquanti-sse2.asm
  src/simd/x86_64/jccolor-avx2.asm
  src/simd/x86_64/jcgray-avx2.asm
  src/simd/x86_64/jcsample-avx2.asm
  src/simd/x86_64/jdcolor-avx2.asm
  src/simd/x86_64/jdmerge-avx2.asm
  src/simd/x86_64/jdsample-avx2.asm
  src/simd/x86_64/jfdctint-avx2.asm
  src/simd/x86_64/jidctint-avx2.asm
  src/simd/x86_64/jquanti-avx2.asm
  src/simd/x86_64/jsimd.c

  # Configs
  ${CMAKE_INSTALL_PREFIX}/include/jconfig.h
  ${CMAKE_INSTALL_PREFIX}/lib/include/jconfigint.h)

set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -D__x86_64__")

if(WIN32)
  set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -DWIN64")
else()
  set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -DELF")
endif()

if(NOT WIN32)
  set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -DPIC")
endif()

set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -I\"${CMAKE_CURRENT_SOURCE_DIR}/src/simd/nasm/\"")
set(CMAKE_ASM_NASM_FLAGS "${CMAKE_ASM_NASM_FLAGS} -I\"${CMAKE_CURRENT_SOURCE_DIR}/src/simd/x86_64/\"")

# Library
add_library(jpeg ${headers} ${sources})
target_include_directories(jpeg PUBLIC src)
target_compile_definitions(jpeg PRIVATE BMP_SUPPORTED GIF_SUPPORTED PPM_SUPPORTED TARGA_SUPPORTED)

if(WIN32)
  target_compile_definitions(jpeg PRIVATE USE_SETMODE)
endif()

if(WIN32 AND BUILD_SHARED_LIBS)
  target_sources(jpeg PRIVATE src/win/jpeg8.def)
  set_target_properties(jpeg PROPERTIES
    DEFINE_SYMBOL DLLDEFINE)
endif()

if(MSVC)
  target_compile_options(jpeg PRIVATE $<$<COMPILE_LANGUAGE:C>:/wd4996>)
else()
  target_compile_options(jpeg PRIVATE $<$<COMPILE_LANGUAGE:C>:-Wno-sign-compare -Wno-clobbered>)
endif()

# Install
install(TARGETS jpeg)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:jpeg> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
