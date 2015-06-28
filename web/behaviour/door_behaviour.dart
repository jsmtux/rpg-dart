library door_behaviour;

import 'package:vector_math/vector_math.dart';

import 'terrain_element_behaviour.dart';
import 'behaviour.dart';
import "../game_area.dart";
import '../drawable.dart';

class DoorBehaviour extends Tile3dBehaviour
{
  String name_;

  DoorBehaviour(Vector2 position, GameArea area, this.name_) : super(position, 1.0, area);

  void init(Drawable drawable)
  {
    super.init(drawable);
  }

  void open()
  {
    drawable_.setScale(1.0);
  }

  void close()
  {
    drawable_.setScale(0.3);
  }

  void update()
  {
  }
}