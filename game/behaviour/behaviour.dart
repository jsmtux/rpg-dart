library behaviour;

import 'package:vector_math/vector_math.dart';

import '../drawable.dart';

abstract class Behaviour
{
  Drawable drawable_;
  void init(Drawable drawable)
  {
    drawable_ = drawable;
  }
  void update();
}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}
