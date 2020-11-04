cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(png VERSION 1.6.37 LANGUAGES C)

set(URL "https://downloads.sourceforge.net/project/libpng/libpng16/${PROJECT_VERSION}/libpng-${PROJECT_VERSION}.tar.gz")
set(SHA "daeb2620d829575513e35fecc83f0d3791a620b9b93d800b763542ece9390fb4")
download_source(${URL} ${SHA} src configure.patch)

# Configs
configure_file(src/scripts/pnglibconf.h.prebuilt
  ${CMAKE_INSTALL_PREFIX}/include/pnglibconf.h)

# Headers
set(headers
  src/png.h
  src/pngconf.h)

# Sources
set(sources
  src/pngpriv.h
  src/pngdebug.h
  src/pnginfo.h
  src/pngstruct.h
  src/png.c
  src/pngerror.c
  src/pngget.c
  src/pngmem.c
  src/pngpread.c
  src/pngread.c
  src/pngrio.c
  src/pngrtran.c
  src/pngrutil.c
  src/pngset.c
  src/pngtrans.c
  src/pngwio.c
  src/pngwrite.c
  src/pngwtran.c
  src/pngwutil.c
  src/intel/intel_init.c
  src/intel/filter_sse2_intrinsics.c
  ${CMAKE_INSTALL_PREFIX}/include/pnglibconf.h)

# Library
add_library(png ${headers} ${sources})
target_include_directories(png PRIVATE src)
target_compile_definitions(png PRIVATE PNG_INTEL_SSE_OPT=1)
target_link_libraries(png PRIVATE ace::zlib)

if(WIN32)
  target_compile_definitions(png PRIVATE _CRT_SECURE_NO_DEPRECATE)
endif()

if(WIN32 AND BUILD_SHARED_LIBS)
  target_compile_definitions(png PRIVATE PNG_BUILD_DLL)
endif()

if(MSVC)
  target_compile_options(png PRIVATE /wd5105)
endif()

# Install
install(TARGETS png)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:png> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
