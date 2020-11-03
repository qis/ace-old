#include <ice/async.hpp>
#include <ice/context.hpp>
#include <application.hpp>
#include <fmt/format.h>
#include <memory_resource>
#include <thread>
#include <cassert>
#include <cstdint>

int main(int argc, char* argv[])
{
  const std::pmr::polymorphic_allocator<char> allocator;

  application application;
  for (std::size_t i = 0; i < 3; i++) {
    fmt::print("value: {}\n", application.value(allocator));
  }

  ice::context c0;
  ice::context c1;

  std::thread t0([&]() {
    c0.run();
  });
  std::thread t1([&]() {
    c1.run();
  });

  [&]() -> ice::task {
    assert(std::this_thread::get_id() != t0.get_id());
    assert(std::this_thread::get_id() != t1.get_id());
    assert(!c0.is_current());
    assert(!c1.is_current());

    co_await c0.schedule(true);
    assert(std::this_thread::get_id() == t0.get_id());
    assert(c0.is_current());
    assert(!c1.is_current());

    co_await c1.schedule(true);
    assert(std::this_thread::get_id() == t1.get_id());
    assert(!c0.is_current());
    assert(c1.is_current());

    co_await c1.schedule();
    assert(std::this_thread::get_id() == t1.get_id());
    assert(!c0.is_current());
    assert(c1.is_current());

    co_await c0.schedule();
    assert(std::this_thread::get_id() == t0.get_id());
    assert(c0.is_current());
    assert(!c1.is_current());

    c0.stop();
    c1.stop();
  }();

  t0.join();
  t1.join();
}
