#include <raycommon.h>
#include <valarray>

Tuple::Tuple(float x_e, float y_e, float z_e, int w_e): x(x_e), y(y_e), z(z_e), w(w_e)
{}

Tuple Tuple::createPoint(float x_e, float y_e, float z_e) {
  return Tuple(x_e, y_e, z_e, 1);
}

Tuple Tuple::createVector(float x_e, float y_e, float z_e) {
  return Tuple(x_e, y_e, z_e, 0);
}

bool Tuple::isPoint() const
{
  if(w == 1)
    return true;
  else
    return false;
}

bool Tuple::isVector() const
{
  if(w == 0)
    return true;
  else
    return false;
}

bool Tuple::operator==(const Tuple& other) const {
  if(float_equals(x, other.x) && float_equals(y, other.y) && float_equals(z, other.z) && w == other.w)
  {
    return true;
  }
  else
    return false;
}

Tuple Tuple::operator+(const Tuple& other) const {
  return Tuple(x + other.x, y + other.y, z + other.z, w + other.w);
}

Tuple Tuple::operator-(const Tuple & other) const {
  return Tuple(x - other.x, y - other.y, z - other.z, w - other.w);
}

Tuple Tuple::operator-() const {
  return Tuple(-x, -y, -z, -w);
}

bool float_equals(float x, float y) {
  auto static constexpr epsilon{0.00001f};

  if(std::abs(x - y) < epsilon)
  {
    return true;
  }
  else
  {
    return false;
  }
}
