cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(fmt VERSION 7.1.0 LANGUAGES CXX)

set(URL "https://github.com/fmtlib/fmt/archive/${PROJECT_VERSION}.tar.gz")
set(SHA "a53bce7e3b7ee8c7374723262a43356afff176b1684b86061748409e6f8b56c5")
download_source(${URL} ${SHA} src configure.patch)

# Headers
file(GLOB headers src/include/fmt/*.h)

# Sources
file(GLOB sources src/src/*.cc)

# Library
add_library(fmt ${headers} ${sources})
target_include_directories(fmt PUBLIC src/include)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(fmt PRIVATE FMT_EXPORT)
endif()

# Install
install(TARGETS fmt)

if(WIN32 AND BUILD_SHARED_LIBS)
  install(FILES $<TARGET_PDB_FILE:fmt> DESTINATION bin)
endif()

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include/fmt)
endif()
