cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(pugixml VERSION 1.10 LANGUAGES CXX)

set(URL "https://github.com/zeux/pugixml/archive/v${PROJECT_VERSION}.tar.gz")
set(SHA "10f1f0a32b559ca8435d95855928d990cfbb9796e339efb638080c897728174c")
download_source(${URL} ${SHA} src configure.patch)

# Headers
file(GLOB headers
  src/src/*.hpp)

# Sources
file(GLOB sources
  src/src/*.cpp)

# Shared
add_library(pugixml ${headers} ${sources})
target_include_directories(pugixml BEFORE PUBLIC src/src)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(pugixml PRIVATE PUGIXML_EXPORT)
endif()

# Install
install(TARGETS pugixml)

if(NOT SKIP_INSTALL_HEADERS)
  install(FILES ${headers} DESTINATION include)
endif()
