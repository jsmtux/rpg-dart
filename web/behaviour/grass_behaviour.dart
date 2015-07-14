library grass_behaviour;

import 'package:vector_math/vector_math.dart';

import '../game_area.dart';
import 'terrain_element_behaviour.dart';
import 'sheep_behaviour.dart';
import '../drawable.dart';

class GrassBehaviour extends SpriteBehaviour
{
  bool eaten_ = false;
  //Vector3 initial_position_;
  GrassBehaviour(GameArea area, Vector2 pos)
    : super(pos, area)
  {
  }

  void init(Drawable element)
  {
    super.init(element);
    super.update();
  }

  void hit(SpriteBehaviour behaviour)
  {
    if (behaviour is SheepBehaviour)
    {
      eaten_ = true;
      drawable_.setPosition(drawable_.getPosition() + new Vector3(0.0, 0.0, -.5));
    }
  }

  void update()
  {
  }
}