#include <fmt/format.h>

void test()
{
  fmt::print("done\n");
}

int main(int argc, char* argv[])
{
  for (int i = 0; i < 3; i++) {
    test();
  }
}
