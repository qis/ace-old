#include "doctest.h"
#include <application.hpp>

TEST_CASE("value")
{
  application application;
  REQUIRE(application.value() == "0.3");
}

int main(int argc, char* argv[])
{
  doctest::Context context;
  context.applyCommandLine(argc, argv);
  return context.run();
}
