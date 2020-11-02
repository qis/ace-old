cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(tbb VERSION 2020.3 LANGUAGES CXX)

set(URL "https://github.com/oneapi-src/oneTBB/archive/v${PROJECT_VERSION}.tar.gz")
set(SHA "ebc4f6aa47972daed1f7bf71d100ae5bf6931c2e3144cf299c8cc7d041dca2f3")
download_source(${URL} ${SHA} src configure.patch compatibility.patch)

# Version
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/src/version_string.ver
  "#define __TBB_VERSION_STRINGS(N) \"${PROJECT_VERSION}\"\n")

# Export
if(WIN32)
  set(export_flags "/nologo;/TC;/EP;/DTBB_NO_LEGACY")
  list(APPEND export_flags /I"${CMAKE_CURRENT_SOURCE_DIR}/src/include")
  list(APPEND export_flags /I"${CMAKE_CURRENT_SOURCE_DIR}/src/src")
else()
  set(export_flags "-E;-x;c++;-DTBB_NO_LEGACY")
  list(APPEND export_flags -I"${CMAKE_CURRENT_SOURCE_DIR}/src/include")
  list(APPEND export_flags -I"${CMAKE_CURRENT_SOURCE_DIR}/src/src")
endif()

# Sources
file(GLOB_RECURSE sources
  src/include/tbb/*.h)

list(APPEND sources
  src/src/tbb/concurrent_hash_map.cpp
  src/src/tbb/concurrent_queue.cpp
  src/src/tbb/concurrent_vector.cpp
  src/src/tbb/dynamic_link.cpp
  src/src/tbb/itt_notify.cpp
  src/src/tbb/cache_aligned_allocator.cpp
  src/src/tbb/pipeline.cpp
  src/src/tbb/queuing_mutex.cpp
  src/src/tbb/queuing_rw_mutex.cpp
  src/src/tbb/reader_writer_lock.cpp
  src/src/tbb/spin_rw_mutex.cpp
  src/src/tbb/x86_rtm_rw_mutex.cpp
  src/src/tbb/spin_mutex.cpp
  src/src/tbb/critical_section.cpp
  src/src/tbb/mutex.cpp
  src/src/tbb/recursive_mutex.cpp
  src/src/tbb/condition_variable.cpp
  src/src/tbb/tbb_thread.cpp
  src/src/tbb/concurrent_monitor.cpp
  src/src/tbb/semaphore.cpp
  src/src/tbb/private_server.cpp
  src/src/rml/client/rml_tbb.cpp
  src/src/tbb/tbb_misc.cpp
  src/src/tbb/tbb_misc_ex.cpp
  src/src/tbb/task.cpp
  src/src/tbb/task_group_context.cpp
  src/src/tbb/governor.cpp
  src/src/tbb/market.cpp
  src/src/tbb/arena.cpp
  src/src/tbb/scheduler.cpp
  src/src/tbb/observer_proxy.cpp
  src/src/tbb/tbb_statistics.cpp
  src/src/tbb/tbb_main.cpp)

# Export
if(WIN32)
  set(export src/src/tbb/win64-tbb-export.def)
else()
  set(export src/src/tbb/lin64-tbb-export.def)
endif()

# Library
add_library(tbb ${sources})
target_include_directories(tbb BEFORE
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/rml/include
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/include)

target_compile_definitions(tbb
  PRIVATE _WINDLL PUBLIC __TBB_DYNAMIC_LOAD_ENABLED=0)

if(BUILD_SHARED_LIBS)
  add_custom_command(COMMENT "Generating tbb export file..."
    DEPENDS ${export} OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/tbb.def
    COMMAND ${CMAKE_CXX_COMPILER} ${export_flags}
      ${CMAKE_CURRENT_SOURCE_DIR}/${export} > ${CMAKE_CURRENT_BINARY_DIR}/tbb.def
    COMMAND_EXPAND_LISTS)

  target_sources(tbb PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/tbb.def)
endif()

target_compile_definitions(tbb PRIVATE DO_ITT_NOTIFY __TBB_BUILD=1
  TBB_SUPPRESS_DEPRECATED_MESSAGES=1 TBB_NO_LEGACY=1)

if(WIN32)
  target_compile_definitions(tbb PRIVATE USE_WINTHREAD=1)
else()
  target_compile_definitions(tbb PRIVATE USE_PTHREAD=1)
endif()

if(WIN32)
  enable_language(ASM_MASM)
  target_sources(tbb PRIVATE
    src/src/tbb/intel64-masm/atomic_support.asm
    src/src/tbb/intel64-masm/intel64_misc.asm
    src/src/tbb/intel64-masm/itsx.asm)
else()
  target_link_libraries(tbb PRIVATE dl)
  target_compile_options(tbb PRIVATE
    -Wno-keyword-macro
    -Wno-deprecated-copy
    -Wno-deprecated-volatile)
endif()

# Install
install(TARGETS tbb)

if(NOT SKIP_INSTALL_HEADERS)
  install(DIRECTORY src/include/tbb DESTINATION include
    FILES_MATCHING PATTERN "*.h" PATTERN "tbbmalloc_proxy.h" EXCLUDE)
endif()
