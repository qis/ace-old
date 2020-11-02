cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(test VERSION 0.1.0 LANGUAGES CXX)

add_executable(main EXCLUDE_FROM_ALL src/main.cpp src/main.manifest)
target_link_libraries(main PRIVATE ace::fmt)

add_executable(test EXCLUDE_FROM_ALL src/test.cpp src/main.manifest)

target_link_libraries(test PRIVATE
  # Utility
  ace::doctest
  ace::fmt
  ace::tz
  ace::pugixml
  ace::tbb

  # Compression
  ace::brotli
  ace::bzip2
  ace::lzma
  ace::zlib
  ace::zstd)

add_executable(benchmark EXCLUDE_FROM_ALL src/benchmark.cpp src/main.manifest)
target_link_libraries(benchmark PRIVATE ace::benchmark ace::fmt)
