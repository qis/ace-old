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
  set(CMAKE_LINKER "link.exe" CACHE STRING "")
  set(CMAKE_AR "lib.exe" CACHE STRING "")

  # Runtime Library
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Ace>:DLL>$<$<CONFIG:Debug>:DebugDLL>" CACHE STRING "")

  # MSVC Defines
  set(MSVC_DEFINES "/DWIN32 /D_WINDOWS /DWINVER=0x0A00 /D_WIN32_WINNT=0x0A00")
  set(MSVC_DEFINES "${MSVC_DEFINES} /DNOMINMAX /DWIN32_LEAN_AND_MEAN")
  set(MSVC_DEFINES "${MSVC_DEFINES} /D_CRT_SECURE_NO_WARNINGS")
  set(MSVC_DEFINES "${MSVC_DEFINES} /D_HAS_EXCEPTIONS=0")

  # MSVC Flags
  set(MSVC_FLAGS "/WX /W3 /wd4101 /wd26812 /wd28251 /wd4275")
  set(MSVC_FLAGS "${MSVC_FLAGS} /diagnostics:column /FC")
  set(MSVC_FLAGS "${MSVC_FLAGS} ${MSVC_DEFINES} /utf-8")

  # Compiler Flags
  set(CMAKE_C_FLAGS "/arch:AVX2 /permissive- /Zc:__cplusplus ${MSVC_FLAGS}" CACHE STRING "")
  set(CMAKE_C_FLAGS_ACE "/O1 /Oi /GS- /ZI /JMC" CACHE STRING "")
  set(CMAKE_C_FLAGS_DEBUG "/Od /sdl /RTC1 /ZI /JMC" CACHE STRING "")
  set(CMAKE_C_FLAGS_RELEASE "/O2 /GS- /GL /analyze- /DNDEBUG" CACHE STRING "")

  set(CMAKE_CXX_FLAGS "/EHs-c- /GR- ${CMAKE_C_FLAGS}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_ACE "${CMAKE_C_FLAGS_ACE}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "")

  # Linker Flags
  foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
    set(CMAKE_${LINKER}_FLAGS_ACE "/INCREMENTAL /DEBUG:FASTLINK" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_DEBUG "/INCREMENTAL /DEBUG:FASTLINK" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_RELEASE "/OPT:REF /OPT:ICF /LTCG" CACHE STRING "")
  endforeach()

  # Standard Libraries
  set(CMAKE_C_STANDARD_LIBRARIES "kernel32.lib user32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib" CACHE STRING "")
  set(CMAKE_CXX_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES}" CACHE STRING "")

  # Assembler Flags
  set(CMAKE_ASM_MASM_FLAGS_INIT "-nologo")

  # Resource Compiler Flags
  set(CMAKE_RC_FLAGS_INIT "-nologo -c65001 ${MSVC_DEFINES}")
  set(CMAKE_RC_FLAGS_ACE_INIT "")
  set(CMAKE_RC_FLAGS_DEBUG_INIT "/DNDEBUG")
  set(CMAKE_RC_FLAGS_RELEASE_INIT "/DNDEBUG")

  # Link Directories
  link_directories(BEFORE ${CMAKE_CURRENT_LIST_DIR}/lib)

  # Cleanup
  unset(MSVC_DEFINES)
  unset(MSVC_FLAGS)
else()
  # LLVM
  find_program(LLVM_BIN clang PATHS /opt/llvm/bin REQUIRED)
  get_filename_component(LLVM_BIN ${LLVM_BIN} DIRECTORY)
  get_filename_component(LLVM_LIB ${LLVM_BIN} DIRECTORY)
  set(LLVM_LIB ${LLVM_LIB}/lib)

  # Toolset
  set(CMAKE_C_COMPILER "${LLVM_BIN}/bin/clang" CACHE STRING "")
  set(CMAKE_CXX_COMPILER "${LLVM_BIN}/bin/clang++" CACHE STRING "")
  set(CMAKE_RANLIB "${LLVM_BIN}/bin/llvm-ranlib" CACHE STRING "")
  set(CMAKE_AR "${LLVM_BIN}/bin/llvm-ar" CACHE STRING "")
  set(CMAKE_NM "${LLVM_BIN}/bin/llvm-nm" CACHE STRING "")

  # LLVM Defines
  set(LLVM_DEFINES "-D_DEFAULT_SOURCE=1")

  # LLVM Flags
  set(LLVM_FLAGS "-Werror -Wall -Wextra -Wpedantic -Wrange-loop-analysis")
  set(LLVM_FLAGS "${LLVM_FLAGS} -Wno-gnu")
  set(LLVM_FLAGS "${LLVM_FLAGS} -Wno-c++98-compat")
  set(LLVM_FLAGS "${LLVM_FLAGS} -Wno-c++98-compat-pedantic")
  set(LLVM_FLAGS "${LLVM_FLAGS} -Wno-unused-parameter")
  set(LLVM_FLAGS "${LLVM_FLAGS} -Wno-unused-variable")
  set(LLVM_FLAGS "${LLVM_FLAGS} -Wno-nonportable-system-include-path")
  set(LLVM_FLAGS "${LLVM_FLAGS} -Wno-nested-anon-types")
  set(LLVM_FLAGS "${LLVM_FLAGS} -fdiagnostics-absolute-paths")
  set(LLVM_FLAGS "${LLVM_FLAGS} -fcolor-diagnostics")
  set(LLVM_FLAGS "${LLVM_FLAGS} -fansi-escape-codes")

  # Compiler Flags
  set(CMAKE_C_FLAGS "-fasm -mavx2 ${LLVM_FLAGS} ${LLVM_DEFINES}" CACHE STRING "")
  set(CMAKE_C_FLAGS_ACE "-O1 -g" CACHE STRING "")
  set(CMAKE_C_FLAGS_DEBUG "-O0 -g" CACHE STRING "")
  set(CMAKE_C_FLAGS_RELEASE "-O3 -flto=full -DNDEBUG" CACHE STRING "")

  set(CMAKE_CXX_FLAGS "-stdlib=libc++ -fno-exceptions -fno-rtti ${CMAKE_C_FLAGS}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_ACE "${CMAKE_C_FLAGS_ACE}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -fwhole-program-vtables -fvirtual-function-elimination" CACHE STRING "")

  # Linker Flags
  foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
    set(CMAKE_${LINKER}_FLAGS "-L${CMAKE_CURRENT_LIST_DIR}/lib -fuse-ld=lld -pthread -Wl,--as-needed" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_ACE "" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_DEBUG "" CACHE STRING "")
    set(CMAKE_${LINKER}_FLAGS_RELEASE "-Wl,-s -static-libstdc++ ${LLVM_LIB}/lib/libc++abi.a -flto=full" CACHE STRING "")
  endforeach()

  # Position Independent Code
  set(CMAKE_POSITION_INDEPENDENT_CODE_ACE ON CACHE BOOL "")
  set(CMAKE_POSITION_INDEPENDENT_CODE_DEBUG ON CACHE BOOL "")
  set(CMAKE_POSITION_INDEPENDENT_CODE_RELEASE OFF CACHE BOOL "")

  # Runtime Path
  if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_BUILD_RPATH "${LLVM_LIB}/lib;${CMAKE_CURRENT_LIST_DIR}/lib" CACHE STRING "")
  endif()

  # Cleanup
  unset(LLVM_STATIC)
  unset(LLVM_DEFINES)
  unset(LLVM_FLAGS)
  unset(LLVM_LIB)
  unset(LLVM_BIN)
endif()

# Include Directories
include_directories(BEFORE ${CMAKE_CURRENT_LIST_DIR}/include)

# Static Analysis
if(ENABLE_STATIC_ANALYSIS)
  if(WIN32)
    set(ProgramFilesX86 "ProgramFiles(x86)")
    set(ProgramFilesX86 "$ENV{${ProgramFilesX86}}")
    find_program(CLANG_TIDY NAMES clang-tidy PATHS
      $ENV{ProgramW6432}/LLVM/bin
      $ENV{ProgramFiles}/LLVM/bin
      ${ProgramFilesX86}/LLVM/bin)
  else()
    find_program(CLANG_TIDY NAMES clang-tidy PATHS
      /opt/llvm/bin /usr/local/bin /usr/bin)
  endif()

  if(NOT CLANG_TIDY)
    message(FATAL_ERROR "Could not find executable: clang-tidy")
  endif()

  set(CMAKE_C_CLANG_TIDY "${CLANG_TIDY}" CACHE STRING "")
  set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY}" CACHE STRING "")
endif()

# CMake
set(IGNORE_TOOLCHAIN_FILE_VARIABLE "${CMAKE_TOOLCHAIN_FILE}")
mark_as_advanced(IGNORE_TOOLCHAIN_FILE_VARIABLE)

# Ports
set(__PORTS_LIBRARIES)

# Utility
list(APPEND __PORTS_LIBRARIES benchmark doctest fmt tz pugixml tbb)

# Compression
list(APPEND __PORTS_LIBRARIES brotli bzip2 lzma zlib zstd)

# Suffix
set(__PORTS_LIBRARY_SUFFIX "\$<\$<CONFIG:Ace>:a>")
string(APPEND __PORTS_LIBRARY_SUFFIX "$<\$<CONFIG:Debug>:d>")
string(APPEND __PORTS_LIBRARY_SUFFIX "$<\$<CONFIG:Release>:r>")

if(WIN32)
  string(APPEND __PORTS_LIBRARY_SUFFIX ".lib")
endif()

# Import
foreach(port ${__PORTS_LIBRARIES})
  if(NOT TARGET ace::${port})
    add_library(ace::${port} INTERFACE IMPORTED)
    set_target_properties(ace::${port} PROPERTIES
      INTERFACE_LINK_LIBRARIES "${port}${__PORTS_LIBRARY_SUFFIX}")
  endif()
endforeach()

# Dependencies
if(WIN32)
  set_property(TARGET ace::benchmark APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "shlwapi.lib")
else()
  set_property(TARGET ace::brotli APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES "m")
endif()

# Cleanup
unset(__PORTS_LIBRARY_SUFFIX)
unset(__PORTS_LIBRARIES)
