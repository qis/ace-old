#pragma once
#include <ice/async.hpp>
#include <string>

class application {
public:
  application() = default;

  application(application&& other) = delete;
  application(const application& other) = delete;

  application& operator=(application&& other) = delete;
  application& operator=(const application& other) = delete;

  std::string value() const;
  std::string value(std::nullptr_t) const;
  std::pmr::string value(const std::pmr::polymorphic_allocator<char>& allocator) const;
};
