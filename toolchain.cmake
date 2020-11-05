# Toolchain
include_guard(GLOBAL)

# Standard
set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE BOOL "")
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")

set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")

if(WIN32)
  # Toolset
  set(CMAKE_C_COMPILER "cl.exe" CACHE STRING "")
  set(CMAKE_CXX_COMPILER "cl.exe" CACHE STRING "")
  set(CMAKE_RC_COMPILER "rc.exe" CACHE STRING "")
  set(CMAKE_LINKER "link.exe" CACHE STRING "")
  set(CMAKE_AR "lib.exe" CACHE STRING "")

  # Runtime Library
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:RelWithDebInfo>:DLL>$<$<CONFIG:Debug>:DebugDLL>" CACHE STRING "")

  # MSVC Defines
  set(MSVC_DEFINES "/DWIN32 /D_WINDOWS /DWINVER=0x0A00 /D_WIN32_WINNT=0x0A00")
  set(MSVC_DEFINES "${MSVC_DEFINES} /DNOMINMAX /DWIN32_LEAN_AND_MEAN")
  set(MSVC_DEFINES "${MSVC_DEFINES} /D_CRT_SECURE_NO_WARNINGS")

  # MSVC Flags
  set(MSVC_FLAGS "/W3 /wd4101 /wd4275 /wd26812 /wd28251")
  set(MSVC_FLAGS "${MSVC_FLAGS} /diagnostics:column /FC")
  set(MSVC_FLAGS "${MSVC_FLAGS} ${MSVC_DEFINES} /utf-8")

  # Compiler Flags
  set(CMAKE_C_FLAGS "/arch:AVX2 /permissive- /Zc:__cplusplus ${MSVC_FLAGS}" CACHE STRING "")
  set(CMAKE_C_FLAGS_DEBUG "/Od /sdl /RTC1 /ZI /JMC /DACE_SHARED" CACHE STRING "")
  set(CMAKE_C_FLAGS_RELEASE "/O2 /Oi /GS- /GL /analyze- /DNDEBUG" CACHE STRING "")
  set(CMAKE_C_FLAGS_MINSIZEREL "/O1 /Oi /GS- /GL /analyze- /DNDEBUG" CACHE STRING "")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO "/O1 /Oi /GS- /ZI /JMC /DACE_SHARED /DNDEBUG" CACHE STRING "")

  set(CMAKE_CXX_FLAGS "/EHsc ${CMAKE_C_FLAGS}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "")

  # Linker Flags
  foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
    set(CMAKE_${LINKER}_FLAGS "" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_DEBUG "/DEBUG:FASTLINK" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_RELEASE "/OPT:REF /OPT:ICF /INCREMENTAL:NO /LTCG" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_MINSIZEREL "/OPT:REF /OPT:ICF /INCREMENTAL:NO /LTCG" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_RELWITHDEBINFO "/DEBUG:FASTLINK" CACHE STRING "")
  endforeach()

  # Disable logo for compiler and linker.
  set(CMAKE_CL_NOLOGO "/nologo" CACHE STRING "")

  # Standard Libraries
  set(CMAKE_C_STANDARD_LIBRARIES "kernel32.lib user32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib" CACHE STRING "")
  set(CMAKE_CXX_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES}" CACHE STRING "")

  # Assembler Flags
  set(CMAKE_ASM_MASM_FLAGS_INIT "/nologo")

  # Resource Compiler Flags
  set(CMAKE_RC_FLAGS_INIT "/nologo /c65001")
  set(CMAKE_RC_FLAGS_DEBUG_INIT "")
  set(CMAKE_RC_FLAGS_RELEASE_INIT "/DNDEBUG")
  set(CMAKE_RC_FLAGS_MINSIZEREL_INIT "/DNDEBUG")
  set(CMAKE_RC_FLAGS_RELWITHDEBINFO_INIT "/DNDEBUG")

  # Cleanup
  unset(MSVC_DEFINES)
  unset(MSVC_FLAGS)
else()
  # Toolset
  set(CMAKE_C_COMPILER "gcc-10" CACHE STRING "")
  set(CMAKE_CXX_COMPILER "g++-10" CACHE STRING "")
  set(CMAKE_RANLIB "gcc-ranlib-10" CACHE STRING "")
  set(CMAKE_AR "gcc-ar-10" CACHE STRING "")
  set(CMAKE_NM "gcc-nm-10" CACHE STRING "")

  # WARN Flags
  set(WARN_FLAGS "-Wall -Wextra -Wpedantic")
  set(WARN_FLAGS "${WARN_FLAGS} -Wno-unused-parameter")
  set(WARN_FLAGS "${WARN_FLAGS} -Wno-unused-variable")

  # Compiler Flags
  set(CMAKE_C_FLAGS "-mavx2 -fasm ${WARN_FLAGS} -pthread -D_DEFAULT_SOURCE=1" CACHE STRING "")
  set(CMAKE_C_FLAGS_DEBUG "-O0 -g -DACE_SHARED" CACHE STRING "")
  set(CMAKE_C_FLAGS_RELEASE "-O3 -flto -DNDEBUG" CACHE STRING "")
  set(CMAKE_C_FLAGS_MINSIZEREL "-Os -flto -DNDEBUG" CACHE STRING "")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -DACE_SHARED -DNDEBUG" CACHE STRING "")

  set(CMAKE_CXX_FLAGS "-fcoroutines ${CMAKE_C_FLAGS}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -static-libstdc++" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} -static-libstdc++" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "")

  # Linker Flags
  foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
    set(CMAKE_${LINKER}_FLAGS "" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_DEBUG "" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_RELEASE "-Wl,-s -Wl,--as-needed -flto" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_MINSIZEREL "-Wl,-s -Wl,--as-needed -flto" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_RELWITHDEBINFO "" CACHE STRING "")
  endforeach()

  # Position Independent Code
  set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")

  # Runtime Path
  if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE BOOL "")
    set(CMAKE_INSTALL_RPATH "${CMAKE_CURRENT_LIST_DIR}/lib" CACHE STRING "")
  endif()

  # Cleanup
  unset(WARN_FLAGS)
endif()

# Include Directories
include_directories(BEFORE ${CMAKE_CURRENT_LIST_DIR}/include)

# Library Prefix
if(WIN32)
  set(ACE_LIBRARY_PREFIX "${CMAKE_CURRENT_LIST_DIR}/lib/")
else()
  set(ACE_LIBRARY_PREFIX "${CMAKE_CURRENT_LIST_DIR}/lib/lib")
endif()
mark_as_advanced(ACE_LIBRARY_PREFIX)

# Library Suffix
if(WIN32)
  set(ACE_LIBRARY_SUFFIX "$<$<CONFIG:Debug>:d.lib>")
  string(APPEND ACE_LIBRARY_SUFFIX "$<$<CONFIG:Release>:r.lib>")
  string(APPEND ACE_LIBRARY_SUFFIX "$<$<CONFIG:MinSizeRel>:m.lib>")
  string(APPEND ACE_LIBRARY_SUFFIX "$<$<CONFIG:RelWithDebInfo>:i.lib>")
else()
  set(ACE_LIBRARY_SUFFIX "$<$<CONFIG:Debug>:d.so>")
  string(APPEND ACE_LIBRARY_SUFFIX "$<$<CONFIG:Release>:r.a>")
  string(APPEND ACE_LIBRARY_SUFFIX "$<$<CONFIG:MinSizeRel>:m.a>")
  string(APPEND ACE_LIBRARY_SUFFIX "$<$<CONFIG:RelWithDebInfo>:i.so>")
endif()
mark_as_advanced(ACE_LIBRARY_SUFFIX)

if(WIN32)
  set(ACE_BENCHMARK_SUFFIX ${ACE_LIBRARY_SUFFIX})
else()
  set(ACE_BENCHMARK_SUFFIX "$<$<CONFIG:Debug>:d.a>")
  string(APPEND ACE_BENCHMARK_SUFFIX "$<$<CONFIG:Release>:r.a>")
  string(APPEND ACE_BENCHMARK_SUFFIX "$<$<CONFIG:MinSizeRel>:m.a>")
  string(APPEND ACE_BENCHMARK_SUFFIX "$<$<CONFIG:RelWithDebInfo>:i.a>")
endif()
mark_as_advanced(ACE_BENCHMARK_SUFFIX)

if(WIN32)
  set(ACE_DOCTEST_SUFFIX ${ACE_LIBRARY_SUFFIX})
else()
  set(ACE_DOCTEST_SUFFIX "$<$<CONFIG:Debug>:d.so>")
  string(APPEND ACE_DOCTEST_SUFFIX "$<$<CONFIG:Release>:r.so>")
  string(APPEND ACE_DOCTEST_SUFFIX "$<$<CONFIG:MinSizeRel>:m.so>")
  string(APPEND ACE_DOCTEST_SUFFIX "$<$<CONFIG:RelWithDebInfo>:i.so>")
endif()
mark_as_advanced(ACE_DOCTEST_SUFFIX)

# Libraries
set(ACE_LIBRARIES)
list(APPEND ACE_LIBRARIES fmt tz pugixml tbb)
list(APPEND ACE_LIBRARIES brotli bzip2 lzma zlib zstd)
list(APPEND ACE_LIBRARIES jpeg png webp tiff)
mark_as_advanced(ACE_LIBRARIES)

if(NOT TARGET ace::benchmark)
  add_library(ace::benchmark INTERFACE IMPORTED)
  set_target_properties(ace::benchmark PROPERTIES
    INTERFACE_LINK_LIBRARIES "${ACE_LIBRARY_PREFIX}benchmark${ACE_BENCHMARK_SUFFIX}")
endif()

if(NOT TARGET ace::doctest)
  add_library(ace::doctest INTERFACE IMPORTED)
  set_target_properties(ace::doctest PROPERTIES
    INTERFACE_LINK_LIBRARIES "${ACE_LIBRARY_PREFIX}doctest${ACE_DOCTEST_SUFFIX}")
endif()

foreach(port ${ACE_LIBRARIES})
  if(NOT TARGET ace::${port})
    add_library(ace::${port} INTERFACE IMPORTED)
    set_target_properties(ace::${port} PROPERTIES
      INTERFACE_LINK_LIBRARIES "${ACE_LIBRARY_PREFIX}${port}${ACE_LIBRARY_SUFFIX}")
  endif()
endforeach()

# Dependencies
if(WIN32)
  set_property(TARGET ace::benchmark APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "shlwapi.lib")

  set_property(TARGET ace::webp APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "shlwapi.lib;windowscodecs.lib")
else()
  set_property(TARGET ace::tbb APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "dl")

  set_property(TARGET ace::brotli APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "m")

  set_property(TARGET ace::webp APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "m")
endif()

set_property(TARGET ace::png APPEND PROPERTY
  INTERFACE_LINK_LIBRARIES "ace::zlib")

set_property(TARGET ace::webp APPEND PROPERTY
  INTERFACE_LINK_LIBRARIES "ace::jpeg;ace::png")

set_property(TARGET ace::tiff APPEND PROPERTY
  INTERFACE_LINK_LIBRARIES "ace::jpeg;ace::webp;ace::lzma;ace::zlib;ace::zstd")

# CMake
set(IGNORE_TOOLCHAIN_FILE_VARIABLE "${CMAKE_TOOLCHAIN_FILE}")
mark_as_advanced(IGNORE_TOOLCHAIN_FILE_VARIABLE)
