#ifndef RAYCOMMON_HPP
#define RAYCOMMON_HPP

#include <ray/raycommon_export.hpp>

[[nodiscard]] RAYCOMMON_EXPORT int factorial(int) noexcept;

[[nodiscard]] constexpr int factorial_constexpr(int input) noexcept
{
  if (input == 0) { return 1; }

  return input * factorial_constexpr(input - 1);
}

#endif