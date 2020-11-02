#include "application.hpp"
#include <fmt/format.h>

std::string application::value() const
{
  return fmt::format("{:.1}", 0.32);
}
