#include "raycommon.h"
#include <catch2/catch_test_macros.hpp>

#include <ray/raycommon.hpp>

TEST_CASE("Tuple is a point", "[Tuple]")
{
  Tuple point(4.3f, -4.2f, 3.1f, 1);
  REQUIRE(point.isPoint());
  REQUIRE_FALSE(point.isVector());
}

TEST_CASE("Floats are equal", "[Function]")
{
  REQUIRE(float_equals(1.0f, 1.0f));
  REQUIRE_FALSE(float_equals(1.0f, 1.1f));
}

TEST_CASE("Tuple is a vector", "[Tuple]")
{
  Tuple vector(4.3f, -4.2f, 3.1f, 0);
  REQUIRE(vector.isVector());
  REQUIRE_FALSE(vector.isPoint());
}

TEST_CASE("Creates a point", "[Tuple]")
{
  Tuple point = Tuple::createPoint(4.f, -4.f, 3.f);
  REQUIRE(point.isPoint());
  REQUIRE_FALSE(point.isVector());
}

TEST_CASE("Creates a vector", "[Tuple]")
{
  Tuple vector = Tuple::createVector(4.f, -4.f, 3.f);
  REQUIRE(vector.isVector());
  REQUIRE_FALSE(vector.isPoint());
}

TEST_CASE("Tuples are equal", "[Tuple]")
{
  Tuple vector1 = Tuple::createVector(4.f, -4.f, 3.f);
  Tuple vector2 = Tuple::createVector(4.f, -4.f, 3.f);
  Tuple vector3 = Tuple::createVector(5.f, 6.f, 7.f);
  Tuple point = Tuple::createPoint(4.f, -4.f, 3.f);

  REQUIRE(vector1 == vector1);
  REQUIRE(vector1 == vector2);
  REQUIRE(vector2 == vector1);
  REQUIRE_FALSE(vector1 == vector3);
  REQUIRE_FALSE(vector1 == point);
}

TEST_CASE("Can add tuples", "[Tuple]")
{
  Tuple vector1 = Tuple::createVector(0.f, 0.f, 0.f);
  Tuple vector2 = Tuple::createVector(1.f, 5.f, 6.f);
  REQUIRE(vector2 == vector1 + vector2);

  Tuple point = Tuple::createPoint(9.f, 5.f, 4.f);
  Tuple finalPoint = Tuple::createPoint(10.f, 10.f, 10.f);
  REQUIRE(finalPoint == point + vector2);
}

TEST_CASE("Can subtract tuples", "[Tuple]")
{
  Tuple vector1 = Tuple::createVector(1.f, 5.f, 6.f);
  Tuple vectorZero = Tuple::createVector(0.f, 0.f, 0.f);
  REQUIRE(vectorZero == vector1 - vector1);

  Tuple point1 = Tuple::createPoint(3., 2., 1.);
  Tuple point2 = Tuple::createPoint(5., 6., 7.);
  Tuple result = Tuple::createVector(-2., -4., -6.);
  REQUIRE(result == point1 - point2);

  Tuple vector2 = Tuple::createVector(5., 6., 7.);
  Tuple pointResult = Tuple::createPoint(-2., -4., -6.);
  REQUIRE(pointResult == point1 - vector2);
}

TEST_CASE("Negate tuple", "[Tuple]")
{
  Tuple vector = Tuple::createVector(1.f, 5.f, 6.f);
  Tuple negatedVector = Tuple::createVector(-1.f, -5.f, -6.f);

  REQUIRE(negatedVector == -vector);
}