cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(brotli VERSION 1.0.9 LANGUAGES C)

set(URL "https://github.com/google/brotli/archive/v${PROJECT_VERSION}.tar.gz")
set(SHA "f9e8d81d0405ba66d181529af42a3354f838c939095ff99930da6aa9cdf6fe46")
download_source(${URL} ${SHA} src configure.patch)

# Sources
file(GLOB_RECURSE sources
  src/c/include/*.h
  src/c/common/*.h
  src/c/common/*.c
  src/c/dec/*.h
  src/c/dec/*.c
  src/c/enc/*.h
  src/c/enc/*.c)

# Library
add_library(brotli ${sources})
target_include_directories(brotli BEFORE PUBLIC src/c/include)
target_compile_definitions(brotli PRIVATE BROTLI_HAVE_LOG2=1)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(brotli PRIVATE
    BROTLICOMMON_SHARED_COMPILATION
    BROTLIDEC_SHARED_COMPILATION
    BROTLIENC_SHARED_COMPILATION)
endif()

if(NOT WIN32)
  target_link_libraries(brotli PRIVATE m)
endif()

# Install
install(TARGETS brotli)

if(NOT SKIP_INSTALL_HEADERS)
  install(DIRECTORY src/c/include/brotli DESTINATION include)
endif()
