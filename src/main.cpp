#include <application.hpp>
#include <fmt/format.h>
#include <memory_resource>
#include <cstdint>

int main(int argc, char* argv[])
{
  const std::pmr::polymorphic_allocator<char> allocator;

  application application;
  for (std::size_t i = 0; i < 3; i++) {
    fmt::print("value: {}\n", application.value(allocator));
  }
}
