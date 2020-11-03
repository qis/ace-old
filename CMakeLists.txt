cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(test VERSION 0.1.0 LANGUAGES CXX)

# Application
add_executable(main EXCLUDE_FROM_ALL src/main.cpp src/main.manifest)
target_link_libraries(main PRIVATE ace::fmt)

# Tests
add_executable(tests EXCLUDE_FROM_ALL src/test.cpp src/main.manifest)
target_link_libraries(tests PRIVATE
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

# Benchmarks
add_executable(benchmarks EXCLUDE_FROM_ALL src/benchmark.cpp src/main.manifest)
target_link_libraries(benchmarks PRIVATE ace::benchmark)
