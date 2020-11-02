cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(date VERSION 3.0.0 LANGUAGES CXX)

set(URL "https://github.com/HowardHinnant/date/archive/v${PROJECT_VERSION}.tar.gz")
set(SHA "87bba2eaf0ebc7ec539e5e62fc317cb80671a337c1fb1b84cb9e4d42c6dbebe3")
download_source(${URL} ${SHA} src configure.patch compatibility.patch tzdata.patch)

# Headers
set(headers
  src/include/date/date.h
  src/include/date/iso_week.h
  src/include/date/julian.h
  src/include/date/tz.h)

# Sources
set(sources src/src/tz.cpp)

# Shared
add_library(tz ${headers} ${sources})
target_include_directories(tz BEFORE PUBLIC src/include)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(tz PRIVATE DATE_BUILD_DLL)
endif()

# Install
install(TARGETS tz)

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include/date)

  if(WIN32 AND NOT IS_DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib/tzdata)
    include(${CMAKE_CURRENT_LIST_DIR}/tzdata.cmake)
    tzdata(${CMAKE_INSTALL_PREFIX}/lib/tzdata 2020d)
  endif()
endif()
