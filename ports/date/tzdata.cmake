# Time Zone Database
# http://www.iana.org/time-zones

include_guard(GLOBAL)

function(tzdata destination version)
  if(WIN32 AND NOT EXISTS ${destination}/windowsZones.xml)
    if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/windowsZones.xml)
      message(STATUS "Downloading windowsZones.xml ...")
      file(DOWNLOAD "https://raw.githubusercontent.com/unicode-org/cldr/master/common/supplemental/windowsZones.xml"
        ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/windowsZones.xml)
    endif()
    file(COPY ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/windowsZones.xml DESTINATION ${destination})
  endif()

  set(tzdata_names
    africa
    antarctica
    asia
    australasia
    backward
    etcetera
    europe
    #pacificnew
    northamerica
    southamerica
    #systemv
    leapseconds
    version)

  foreach(name ${tzdata_names})
    if(NOT EXISTS ${destination}/${name})
      if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/${name})
        if(NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata${version}.tar.gz)
          message(STATUS "Downloading tzdata${version}.tar.gz ...")
          file(DOWNLOAD "https://data.iana.org/time-zones/releases/tzdata${version}.tar.gz"
            ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata${version}.tar.gz)
        endif()
        execute_process(COMMAND ${CMAKE_COMMAND} -E
          tar xf ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata${version}.tar.gz
          WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata)
      endif()
      file(COPY ${CMAKE_CURRENT_BINARY_DIR}/download/tzdata/${name} DESTINATION ${destination})
    endif()
  endforeach()
endfunction()
