cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(benchmark VERSION 1.5.2 LANGUAGES CXX)

set(URL "https://github.com/google/benchmark/archive/v1.5.2.tar.gz")
set(SHA "dccbdab796baa1043f04982147e67bb6e118fe610da2c65f88912d73987e700c")
download_source(${URL} ${SHA} src)

# Headers
file(GLOB headers src/include/benchmark/benchmark.h)

# Sources
file(GLOB sources src/src/*.h src/src/*.cc)

foreach(source ${sources})
  if(source MATCHES "benchmark_main.cc")
    list(REMOVE_ITEM sources ${source})
  endif()
endforeach()

# Library
add_library(benchmark STATIC ${headers} ${sources})
target_include_directories(benchmark PRIVATE src/include)

if(WIN32)
  target_link_libraries(benchmark PRIVATE shlwapi)
endif()

if(MSVC)
  target_compile_options(benchmark PRIVATE /wd4722)
else()
  target_compile_options(benchmark PRIVATE -Wno-stringop-truncation)
endif()

if(MSVC AND BUILD_SHARED_LIBS)
  set_target_properties(benchmark PROPERTIES
    COMPILE_PDB_NAME_DEBUG benchmarkd
    COMPILE_PDB_NAME_RELEASE benchmarkr
    COMPILE_PDB_NAME_MINSIZEREL benchmarkm
    COMPILE_PDB_NAME_RELWITHDEBINFO benchmarki
    COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
endif()

# Install
install(TARGETS benchmark)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/$<TARGET_FILE_BASE_NAME:benchmark>.pdb
    DESTINATION lib)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include/benchmark)
endif()
