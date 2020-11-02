cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(application DESCRIPTION "Application" VERSION 0.1.0 LANGUAGES CXX)

# Version
set(PROJECT_VENDOR "Vendor")
configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

# Sources
set(sources
  src/application.hpp
  src/application.cpp)

# Objects
add_library(objects OBJECT ${sources})

target_include_directories(objects PUBLIC
  ${CMAKE_CURRENT_BINARY_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/src)

target_link_libraries(objects PUBLIC ace::fmt)

# Application
add_executable(${PROJECT_NAME} src/main.cpp src/main.manifest src/main.rc)
target_link_libraries(${PROJECT_NAME} PRIVATE objects)

# Test
add_executable(test EXCLUDE_FROM_ALL src/test.cpp src/main.manifest)
target_link_libraries(test PRIVATE objects ace::doctest)

# Benchmark
add_executable(benchmark EXCLUDE_FROM_ALL src/benchmark.cpp src/main.manifest)
target_link_libraries(benchmark PRIVATE objects ace::benchmark)

# Install
install(TARGETS ${PROJECT_NAME} DESTINATION .)
