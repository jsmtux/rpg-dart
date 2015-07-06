library grass_behaviour;

import 'package:vector_math/vector_math.dart';

import '../game_area.dart';
import 'behaviour.dart';
import 'terrain_element_behaviour.dart';
import 'sheep_behaviour.dart';

class GrassBehaviour extends SpriteBehaviour
{
  GrassBehaviour(GameArea area, Vector2 pos)
    : super(pos, area)
  {
  }
}