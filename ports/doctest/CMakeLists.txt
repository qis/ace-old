cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(doctest VERSION 2.4.0 LANGUAGES CXX)

set(URL "https://github.com/onqtam/doctest/archive/${PROJECT_VERSION}.tar.gz")
set(SHA "f689f48e92c088928d88d8481e769c8e804f0a608b484ab8ef3d6ab6045b5444")
download_source(${URL} ${SHA} src configure.patch fix-verbosity.patch)

# Headers
set(headers src/doctest/doctest.h)

# Sources
set(sources src/doctest/parts/doctest.cpp)

# Library
add_library(doctest SHARED ${headers} ${sources})
target_include_directories(doctest BEFORE PUBLIC src/doctest)

target_compile_definitions(doctest
  PRIVATE
    DOCTEST_CONFIG_IMPLEMENT
  PUBLIC
    DOCTEST_CONFIG_IMPLEMENTATION_IN_DLL
    DOCTEST_CONFIG_NO_EXCEPTIONS_BUT_WITH_ALL_ASSERTS
    DOCTEST_CONFIG_USE_IOSFWD)

# Install
install(TARGETS doctest)

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
