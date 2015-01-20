library behaviour;

import 'package:vector_math/vector_math.dart';

import 'element.dart';
import 'game_state.dart';
import 'drawable.dart';
import 'base_geometry.dart';

abstract class Behaviour
{
  void init(EngineElement parent);
  void update(GameState state);
}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}
