cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(tbb VERSION 2021.1 LANGUAGES CXX)

set(URL "https://github.com/oneapi-src/oneTBB/archive/v${PROJECT_VERSION}-beta10.tar.gz")
set(SHA "58ea0767d021e90f9341c4a0bffd4d5e7f782963df9d7b6237577c4f81bd584a")
download_source(${URL} ${SHA} src)

# Sources
file(GLOB_RECURSE sources
  src/include/tbb/*.h)

list(APPEND sources
  src/src/tbb/allocator.cpp
  src/src/tbb/arena.cpp
  src/src/tbb/arena_slot.cpp
  src/src/tbb/concurrent_monitor.cpp
  src/src/tbb/concurrent_bounded_queue.cpp
  src/src/tbb/dynamic_link.cpp
  src/src/tbb/exception.cpp
  src/src/tbb/governor.cpp
  src/src/tbb/global_control.cpp
  src/src/tbb/itt_notify.cpp
  src/src/tbb/main.cpp
  src/src/tbb/market.cpp
  src/src/tbb/misc.cpp
  src/src/tbb/misc_ex.cpp
  src/src/tbb/observer_proxy.cpp
  src/src/tbb/parallel_pipeline.cpp
  src/src/tbb/private_server.cpp
  src/src/tbb/profiling.cpp
  src/src/tbb/rml_tbb.cpp
  src/src/tbb/rtm_mutex.cpp
  src/src/tbb/rtm_rw_mutex.cpp
  src/src/tbb/semaphore.cpp
  src/src/tbb/small_object_pool.cpp
  src/src/tbb/task.cpp
  src/src/tbb/task_dispatcher.cpp
  src/src/tbb/task_group_context.cpp
  src/src/tbb/version.cpp
  src/src/tbb/queuing_rw_mutex.cpp)

# Library
add_library(tbb ${sources})
target_include_directories(tbb BEFORE PUBLIC src/include)
target_compile_definitions(tbb PRIVATE __TBB_BUILD __TBB_USE_ITT_NOTIFY)

if(WIN32)
  set(TBB_DEF_FILE_PREFIX "win64")
else()
  set(TBB_DEF_FILE_PREFIX "lin64")
endif()

if(BUILD_SHARED_LIBS)
  target_sources(tbb PRIVATE
    src/src/tbb/def/${TBB_DEF_FILE_PREFIX}-tbb.def)
endif()

if(NOT MSVC)
  target_compile_options(tbb PRIVATE -mrtm -flifetime-dse=1 -Wno-parentheses)
  target_link_libraries(tbb PRIVATE dl)
endif()

# Install
install(TARGETS tbb)

if(NOT SKIP_INSTALL_HEADERS)
  install(DIRECTORY src/include/tbb DESTINATION include FILES_MATCHING
    PATTERN "tbbmalloc_proxy.h" EXCLUDE
    PATTERN "*.h")
endif()
