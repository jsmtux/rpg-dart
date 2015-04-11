library behaviour;

import 'package:vector_math/vector_math.dart';

import '../game_area.dart';
import '../drawable.dart';

abstract class Behaviour
{
  void init(Drawable drawable);
  void update(GameArea area);
}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}
