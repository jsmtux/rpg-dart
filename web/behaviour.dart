library behaviour;

import 'package:vector_math/vector_math.dart';

import 'element.dart';
import 'game_state.dart';
import 'drawable.dart';

abstract class Behaviour
{
  void init(EngineElement parent);
  void update(GameState state);
}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}

class Tile3dBehaviour extends Behaviour
{
  int x_, y_;
  Tile3dBehaviour(this.x_, this.y_);
  Drawable drawable_;

  void init(EngineElement parent)
  {
    drawable_ = parent.drawable_;
    drawable_.setPosition(new Vector3(x_*1.0, y_*1.0, 0.0));
  }
  void update(GameState state)
  {
  }
}