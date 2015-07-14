library button_behaviour;

import 'package:vector_math/vector_math.dart';

import 'terrain_element_behaviour.dart';
import 'door_behaviour.dart';
import 'behaviour.dart';
import 'grass_behaviour.dart';
import "../game_area.dart";
import '../drawable.dart';

class ButtonBehaviour extends Tile3dBehaviour
{
  Vector3 initial_pos_;
  String object_;
  DoorBehaviour object_found_;
  ButtonBehaviour(Vector2 position, GameArea area, this.object_) : super(position, 0.1, area);

  void init(Drawable drawable)
  {
    super.init(drawable);
    offset_ = new Vector3(0.0, 0.5, 0.0);
    initial_pos_ = drawable_.getPosition();
  }

  void findObject()
  {
    if (object_ != null)
    {
      if (object_found_ == null)
      {
        for (Behaviour behaviour in area_.behaviours_)
        {
          if (behaviour is DoorBehaviour && behaviour.name_ == object_)
          {
            object_found_ = behaviour;
            break;
          }
        }
      }
      if (object_found_ == null)
      {
        print("object $object_ not found!");
      }
    }
  }

  void deActivate()
  {
    findObject();
    if (object_found_ != null)
    {
      object_found_.close();
    }
  }

  void activate()
  {
    findObject();
    if (object_found_ != null)
    {
      object_found_.open();
    }
  }

  void update()
  {
    double height = 0.0;
    bool activated = false;
    for (Behaviour behaviour in area_.behaviours_)
    {
      if (behaviour is TerrainElementBehaviour && !(behaviour is ButtonBehaviour) && !(behaviour is GrassBehaviour))
      {
        TerrainElementBehaviour element = behaviour;

        if (element.squareDistance(this) < 0.25)
        {
          height = -0.1;
          activated = true;
        }
      }
    }
    if (activated)
    {
      activate();
    }
    else
    {
      deActivate();
    }
    drawable_.setPosition(initial_pos_ + new Vector3(0.0,0.0,height));
  }
}