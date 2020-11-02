#pragma once
#include <string>

class application {
public:
  application() = default;

  application(application&& other) = delete;
  application(const application& other) = delete;

  application& operator=(application&& other) = delete;
  application& operator=(const application& other) = delete;

  std::string value() const;
};
