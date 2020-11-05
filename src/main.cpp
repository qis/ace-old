#include <fmt/ostream.h>
#include <coroutine>
#include <stdexcept>
#include <thread>

auto switch_to_new_thread(std::jthread& thread)
{
  struct awaitable {
    std::jthread* thread_;

    bool await_ready()
    {
      return false;
    }

    void await_suspend(std::coroutine_handle<> handle)
    {
      auto& thread = *thread_;
      if (thread.joinable()) {
        throw std::runtime_error("output jthread parameter not empty");
      }

      thread = std::jthread([handle] {
        handle.resume();
      });

      fmt::print("coro: {}\n", thread.get_id());  // this is OK
    }

    void await_resume() {}
  };

  return awaitable{ &thread };
}

struct task {
  struct promise_type {
    constexpr task get_return_object() noexcept
    {
      return {};
    }

    constexpr auto initial_suspend() noexcept
    {
      return std::suspend_never{};
    }

    constexpr auto final_suspend() noexcept
    {
      return std::suspend_never{};
    }

    constexpr void return_void() noexcept {}
    constexpr void unhandled_exception() noexcept {}
  };
};

task resuming_on_new_thread(std::jthread& out) noexcept
{
  fmt::print("0001: {}\n", std::this_thread::get_id());
  co_await switch_to_new_thread(out);
  fmt::print("0002: {}\n", std::this_thread::get_id());
}

int main(int argc, char* argv[])
{
  std::jthread out;
  fmt::print("main: {}\n", std::this_thread::get_id());
  resuming_on_new_thread(out);
}
