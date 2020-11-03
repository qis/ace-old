#include "doctest.h"
#include <ice/async.hpp>
#include <ice/context.hpp>
#include <application.hpp>
#include <thread>

TEST_CASE("value")
{
  application application;
  REQUIRE(application.value() == "0.3");
}

TEST_CASE("ice")
{
  ice::context c0;
  ice::context c1;

  std::thread t0([&]() {
    c0.run();
  });
  std::thread t1([&]() {
    c1.run();
  });

  [&]() -> ice::task {
    REQUIRE(std::this_thread::get_id() != t0.get_id());
    REQUIRE(std::this_thread::get_id() != t1.get_id());
    REQUIRE(!c0.is_current());
    REQUIRE(!c1.is_current());

    co_await c0.schedule(true);
    REQUIRE(std::this_thread::get_id() == t0.get_id());
    REQUIRE(c0.is_current());
    REQUIRE(!c1.is_current());

    co_await c1.schedule(true);
    REQUIRE(std::this_thread::get_id() == t1.get_id());
    REQUIRE(!c0.is_current());
    REQUIRE(c1.is_current());

    co_await c1.schedule();
    REQUIRE(std::this_thread::get_id() == t1.get_id());
    REQUIRE(!c0.is_current());
    REQUIRE(c1.is_current());

    co_await c0.schedule();
    REQUIRE(std::this_thread::get_id() == t0.get_id());
    REQUIRE(c0.is_current());
    REQUIRE(!c1.is_current());

    c0.stop();
    c1.stop();
  }();

  t0.join();
  t1.join();
}

int main(int argc, char* argv[])
{
  doctest::Context context;
  context.applyCommandLine(argc, argv);
  return context.run();
}
