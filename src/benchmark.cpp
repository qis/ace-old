#include "benchmark.h"
#include <application.hpp>
#include <memory_resource>
#include <cstdlib>

static void value_string(benchmark::State& state)
{
  application application;
  for (auto _ : state) {
    const auto value = application.value();
    benchmark::DoNotOptimize(value);
  }
}
BENCHMARK(value_string);

static void value_it_string(benchmark::State& state)
{
  application application;
  for (auto _ : state) {
    const auto value = application.value(nullptr);
    benchmark::DoNotOptimize(value);
  }
}
BENCHMARK(value_it_string);

static void value_pmr_string(benchmark::State& state)
{
  const std::pmr::polymorphic_allocator<char> allocator;
  application application;
  for (auto _ : state) {
    const auto value = application.value(allocator);
    benchmark::DoNotOptimize(value);
  }
}
BENCHMARK(value_pmr_string);

int main(int argc, char** argv)
{
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return EXIT_FAILURE;
  }
  benchmark::RunSpecifiedBenchmarks();
}
