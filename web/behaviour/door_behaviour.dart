library door_behaviour;

import 'package:vector_math/vector_math.dart';

import 'terrain_element_behaviour.dart';
import "behaviour.dart";
import "../game_area.dart";
import '../drawable.dart';

class DoorBehaviour extends Tile3dBehaviour
{
  String name_;
  bool closed_;
  bool passing_ = false;

  DoorBehaviour(Vector2 position, GameArea area, this.name_) : super(position, 1.0, area);

  void init(Drawable drawable)
  {
    super.init(drawable);
    offset_ = new Vector3(0.0, 0.5, 0.0);
  }

  void open()
  {
    AnimatedGeometry anim_drawable = drawable_;
    anim_drawable.setModel(1);
    closed_ = false;
  }

  void close()
  {
    if (!passing_)
    {
      AnimatedGeometry anim_drawable = drawable_;
      anim_drawable.setModel(0);
      closed_ = true;
    }
  }

  void update()
  {
    passing_ = false;
    for (Behaviour behaviour in area_.behaviours_)
    {
      if (behaviour is TerrainElementBehaviour && !(behaviour is DoorBehaviour))
      {
        TerrainElementBehaviour element = behaviour;

        if (element.squareDistance(this) < 0.5)
        {
          passing_ = true;
        }
      }
    }
  }

  double getHeight()
  {
    return closed_? 1.0 : 0.0;
  }
}