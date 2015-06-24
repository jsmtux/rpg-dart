library button_behaviour;

import 'package:vector_math/vector_math.dart';

import 'terrain_element_behaviour.dart';
import 'behaviour.dart';
import "../game_area.dart";
import '../drawable.dart';

class ButtonBehaviour extends Tile3dBehaviour
{
  Vector3 initial_pos_;
  ButtonBehaviour(Vector2 position, GameArea area) : super(position, 0.1, area);

  void init(Drawable drawable)
  {
    super.init(drawable);
    offset_ = new Vector3(-0.5, 0.5, 0.0);
    initial_pos_ = drawable_.getPosition();
  }
  void update()
  {
    double height = 0.0;
    for (Behaviour behaviour in area_.behaviours_)
    {
      if (behaviour is TerrainElementBehaviour && !(behaviour is ButtonBehaviour))
      {
        TerrainElementBehaviour element = behaviour;

        if (element.squareDistance(this) < 0.25)
        {
          height = -0.1;
        }
      }
    }
    drawable_.setPosition(initial_pos_ + new Vector3(0.0,0.0,height));
  }
}