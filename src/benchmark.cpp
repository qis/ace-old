#include <benchmark.h>
#include <cstdio>

static void version_sscanf(benchmark::State& state)
{
  for (auto _ : state) {
    unsigned long major = 0;
    unsigned long minor = 0;
    unsigned long patch = 0;
    [[maybe_unused]] const auto count = std::sscanf("1.2.3", "%lu.%lu.%lu", &major, &minor, &patch);
    assert(count == 3);
    assert(major <= 0xFF);
    assert(minor <= 0xFFF);
    assert(patch <= 0xFFF);
    const auto v = (major << 24) + (minor << 12) + patch;
    benchmark::DoNotOptimize(v);
  }
}
BENCHMARK(version_sscanf);

int main(int argc, char** argv)
{
  benchmark::Initialize(&argc, argv);
  if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
    return 1;
  }
  benchmark::RunSpecifiedBenchmarks();
}
