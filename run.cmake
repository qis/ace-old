execute_process(
  COMMAND ninja -C "${CMAKE_ARGV3}" -f build-${CMAKE_ARGV4}.ninja -t query ${CMAKE_ARGV5}
  OUTPUT_VARIABLE INFO)

string(REGEX REPLACE ";" "\\\\;" INFO "${INFO}")
string(REGEX REPLACE "\n" ";" INFO "${INFO}")

set(STATE 0)
foreach(line ${INFO})
  if(STATE EQUAL 0)
    if(line MATCHES "^[\t ]*${CMAKE_ARGV5}:[\\t ]*$")
      set(STATE 1)
    endif()
  elseif(STATE EQUAL 1)
    if(line MATCHES "^[\t ]*input:")
      set(STATE 2)
    endif()
  elseif(STATE EQUAL 2)
    string(REGEX REPLACE "\t" "" EXE "${line}")
    string(REPLACE " " "" EXE "${line}")
    set(STATE 3)
  endif()
endforeach()

execute_process(COMMAND "${CMAKE_ARGV3}/${EXE}")
