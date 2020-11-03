#include "application.hpp"
#include <fmt/format.h>
#include <memory_resource>

std::string application::value() const
{
  return fmt::format("{:.1}", 0.32);
}

std::string application::value(std::nullptr_t) const
{
  std::string s;
  fmt::format_to(std::back_insert_iterator(s), "{:.1}", 0.32);
  return s;
}

std::pmr::string application::value(const std::pmr::polymorphic_allocator<char>& allocator) const
{
  std::pmr::string s{ allocator };
  fmt::format_to(std::back_insert_iterator(s), "{:.1}", 0.32);
  return s;
}
