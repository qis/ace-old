#include <application.hpp>
#include <fmt/format.h>

int main(int argc, char* argv[])
{
  application application;
  for (std::size_t i = 0; i < 3; i++) {
    fmt::print("value: {}\n", application.value());
  }
}
