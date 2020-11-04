# Toolchain
include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/../toolchain.cmake")

set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "")
set(CMAKE_RELEASE_POSTFIX "r" CACHE STRING "")
set(CMAKE_MINSIZEREL_POSTFIX "m" CACHE STRING "")
set(CMAKE_RELWITHDEBINFO_POSTFIX "i" CACHE STRING "")

if(WIN32)
  set(CMAKE_C_FLAGS_DEBUG "/Od /RTC1 /Zi /DACE_SHARED" CACHE STRING "" FORCE)
  set(CMAKE_C_FLAGS_RELWITHDEBINFO "/O1 /Oi /GS- /Zi /DACE_SHARED /DNDEBUG" CACHE STRING "" FORCE)
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "" FORCE)
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)
  foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
    set(CMAKE_${LINKER}_FLAGS_DEBUG "/OPT:REF /DEBUG:FULL /INCREMENTAL:NO" CACHE STRING "" FORCE)
    set(CMAKE_${LINKER}_FLAGS_RELWITHDEBINFO "/OPT:REF /DEBUG:FULL /INCREMENTAL:NO" CACHE STRING "" FORCE)
  endforeach()  
else()
  foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
    set(CMAKE_${LINKER}_FLAGS_RELEASE "-Wl,-s -flto" CACHE STRING "" FORCE)
    set(CMAKE_${LINKER}_FLAGS_MINSIZEREL "-Wl,-s -flto" CACHE STRING "" FORCE)
  endforeach()
  if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_INSTALL_RPATH "${CMAKE_BUILD_RPATH}" CACHE STRING "")
  endif()
endif()

if(NOT CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  set(SKIP_INSTALL_HEADERS ON CACHE STRING "")
endif()

function(download_source URL SHA DST)
  # Make destination absolute.
  get_filename_component(__DST ${DST} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

  # Check if destination already exists.
  if(IS_DIRECTORY ${__DST})
    return()
  endif()

  # Get file extension.
  get_filename_component(__EXT ${URL} EXT)
  if(NOT __EXT OR __EXT STREQUAL "")
    message(FATAL_ERROR "Missing file extension: ${URL}")
  endif()

  # Set temporary file and directory.
  set(__ZIP ${CMAKE_CURRENT_BINARY_DIR}/${SHA}${__EXT})
  set(__SRC ${CMAKE_CURRENT_BINARY_DIR}/${SHA})

  # Download temporary file.
  if(NOT EXISTS ${__ZIP})
    message(STATUS "Downloading: ${URL}")
    file(DOWNLOAD ${URL} ${__ZIP}
      EXPECTED_HASH SHA256=${SHA}
      STATUS DOWNLOAD_STATUS
      INACTIVITY_TIMEOUT 10
      TLS_VERIFY ON)
    list(GET DOWNLOAD_STATUS 0 ERROR_CODE)
    if(NOT ERROR_CODE EQUAL 0)
      file(REMOVE ${__ZIP})
      list(GET DOWNLOAD_STATUS 1 ERROR_MESSAGE)
      message(FATAL_ERROR "Download fialed: ${ERROR_MESSAGE}")
    endif()
  endif()

  # Extract temporary file to temporary directory.
  file(REMOVE_RECURSE ${__SRC})
  file(MAKE_DIRECTORY ${__SRC})
  file(ARCHIVE_EXTRACT INPUT ${__ZIP} DESTINATION ${__SRC})

  # Update temporary directory if it only containes one subdirectory.
  file(GLOB __SUB LIST_DIRECTORIES ON ${__SRC}/*)
  list(LENGTH __SUB __SUB_LEN)
  if(__SUB_LEN EQUAL 1)
    set(__SRC ${__SUB})
  endif()
  unset(__SUB_LEN)
  unset(__SUB)

  # Remove git files.
  file(REMOVE_RECURSE ${__SRC}/.git)

  # Create a git directory.
  execute_process(
    COMMAND git init .
    WORKING_DIRECTORY ${__SRC})

  execute_process(
    COMMAND git config core.filemode false
    WORKING_DIRECTORY ${__SRC})

  execute_process(
    COMMAND git config core.ignorecase false
    WORKING_DIRECTORY ${__SRC})

  execute_process(
    COMMAND git add .
    WORKING_DIRECTORY ${__SRC})

  execute_process(
    COMMAND git commit -m "unmodified"
    WORKING_DIRECTORY ${__SRC})

  # Apply patches to temporary directory.
  foreach(patch ${ARGN})
    message(STATUS "Applying: ${patch}")
    execute_process(
      COMMAND git apply --ignore-whitespace "${CMAKE_CURRENT_SOURCE_DIR}/${patch}"
      WORKING_DIRECTORY ${__SRC})

    execute_process(
      COMMAND git add .
      WORKING_DIRECTORY ${__SRC})

    execute_process(
      COMMAND git commit -m "${patch}"
      WORKING_DIRECTORY ${__SRC})
  endforeach()

  # Move temporary directory to destination.
  file(REMOVE_RECURSE ${__DST})
  file(RENAME ${__SRC} ${__DST})

  # Remove temporary file and directory.
  file(REMOVE_RECURSE ${__SRC})
  file(REMOVE ${__ZIP})

  # Cleanup
  unset(__EXT)
  unset(__SRC)
  unset(__ZIP)
  unset(__DST)
endfunction()
