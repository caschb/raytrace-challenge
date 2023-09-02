#ifndef RAYCOMMON_H
#define RAYCOMMON_H

#include "ray/raycommon_export.hpp"
class Tuple
{
  private:
    float x;
    float y;
    float z;
    int w;
  public:
  Tuple(float, float, float, int);
  static Tuple createPoint(float, float, float);
  static Tuple createVector(float, float, float);
  bool isPoint() const;
  bool isVector() const;
  bool operator==(const Tuple&) const;
  Tuple operator+(const Tuple&) const;
  Tuple operator-(const Tuple&) const;
  Tuple operator*(float) const;
  Tuple operator/(float) const;
  Tuple operator-() const;
};

bool float_equals(float, float);

#endif