// clang-format off
#if defined(__cplusplus) && defined(__INTELLISENSE__)
#include <bits/c++config.h>
#include <compare>

namespace std {

template <typename _Result, typename = void>
struct __coroutine_traits_impl {};

template <typename _Result>
struct __coroutine_traits_impl<_Result, __void_t<typename _Result::promise_type>> {
  using promise_type = typename _Result::promise_type;
};

template <typename _Result, typename...>
struct coroutine_traits : __coroutine_traits_impl<_Result> {};

template <typename _Promise = void>
struct coroutine_handle;

template <>
struct coroutine_handle<void> {
public:
  constexpr coroutine_handle() noexcept;
  constexpr coroutine_handle(std::nullptr_t) noexcept;
  coroutine_handle& operator=(std::nullptr_t) noexcept;
  constexpr void* address() const noexcept;
  constexpr static coroutine_handle from_address(void*) noexcept;
  constexpr explicit operator bool() const noexcept;
  bool done() const noexcept;
  void operator()() const;
  void resume() const;
  void destroy() const;
};

constexpr bool operator==(coroutine_handle<>, coroutine_handle<>) noexcept;
constexpr strong_ordering operator<=>(coroutine_handle<>, coroutine_handle<>) noexcept;

template <typename _Promise>
struct coroutine_handle : coroutine_handle<> {
  using coroutine_handle<>::coroutine_handle;
  static coroutine_handle from_promise(_Promise&);
  coroutine_handle& operator=(std::nullptr_t) noexcept;
  constexpr static coroutine_handle from_address(void*);
  _Promise& promise() const;
};

struct noop_coroutine_promise {};

template <>
struct coroutine_handle<noop_coroutine_promise> : public coroutine_handle<> {
  using _Promise = noop_coroutine_promise;

public:
  constexpr explicit operator bool() const noexcept;
  constexpr bool done() const noexcept;
  void operator()() const noexcept;
  void resume() const noexcept;
  void destroy() const noexcept;
  _Promise& promise() const;

private:
  friend coroutine_handle<noop_coroutine_promise> noop_coroutine() noexcept;

  coroutine_handle() noexcept;
};

using noop_coroutine_handle = coroutine_handle<noop_coroutine_promise>;
inline noop_coroutine_handle noop_coroutine() noexcept { return {}; }

struct suspend_always {
  constexpr bool await_ready() noexcept { return false; }
  constexpr void await_suspend(coroutine_handle<>) noexcept {}
  constexpr void await_resume() noexcept {}
};

struct suspend_never {
  constexpr bool await_ready() noexcept { return true; }
  constexpr void await_suspend(coroutine_handle<>) noexcept {}
  constexpr void await_resume() noexcept {}
};

}  // namespace std
#endif
