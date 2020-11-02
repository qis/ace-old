#include "benchmark.h"
#include <application.hpp>
#include <cstdlib>

static void version_sscanf(benchmark::State& state)
{
  application application;
  for (auto _ : state) {
    const auto value = application.value();
    benchmark::DoNotOptimize(value);
  }
}
BENCHMARK(version_sscanf);

int main(int argc, char** argv)
{
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return EXIT_FAILURE;
  }
  benchmark::RunSpecifiedBenchmarks();
}
