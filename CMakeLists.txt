cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(application DESCRIPTION "Application" VERSION 0.1.0 LANGUAGES CXX)

# Version
set(PROJECT_VENDOR "Vendor")
configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

# Sources
file(GLOB sources
  src/ice/*.hpp
  src/ice/*.cpp
  src/application.hpp
  src/application.cpp)

# Objects
add_library(objects OBJECT ${sources})
target_include_directories(objects PUBLIC src)
target_link_libraries(objects PUBLIC ace::fmt)

# Application
add_executable(${PROJECT_NAME} src/main.cpp src/main.manifest src/main.rc)
target_link_libraries(${PROJECT_NAME} PRIVATE objects)

# Tests
add_executable(tests EXCLUDE_FROM_ALL src/test.cpp src/main.manifest)
target_link_libraries(tests PRIVATE objects ace::doctest)

# Benchmarks
add_executable(benchmarks EXCLUDE_FROM_ALL src/benchmark.cpp src/main.manifest)
target_link_libraries(benchmarks PRIVATE objects ace::benchmark)

# Install
install(TARGETS ${PROJECT_NAME} DESTINATION .)
