library path_follower;

import 'package:vector_math/vector_math.dart';

import 'directions.dart';
import 'behaviour.dart';
import 'path.dart';

abstract class PathFollower
{
  void updateWalk(WalkingBehaviour behaviour);
}

class SquarePathFollower implements PathFollower
{
  int num_steps_ = 0;
  Directions walking_dir_ = Directions.UP;

  void updateWalk(WalkingBehaviour behaviour)
  {
    if (num_steps_ > 100)
    {
      switch(walking_dir_)
      {
        case Directions.UP:
          walking_dir_ = Directions.LEFT;
          break;
        case Directions.DOWN:
          walking_dir_ = Directions.RIGHT;
          break;
        case Directions.LEFT:
          walking_dir_ = Directions.DOWN;
          break;
        case Directions.RIGHT:
          walking_dir_ = Directions.UP;
          break;
      }
      num_steps_ = 0;
    }
    num_steps_++;
    behaviour.walk(walking_dir_);
  }
}

class MapPathFollower implements PathFollower
{
  Path path_;
  int cur_path_point_ = 0;

  MapPathFollower(this.path_);

  void updateWalk(WalkingBehaviour behaviour)
  {
    if (cur_path_point_ >= path_.points.length)
    {
      cur_path_point_ = 0;
    }
    Vector2 position = path_.points[cur_path_point_];
    position = position + path_.position;
    int x = position.x.floor();
    int y = position.y.floor();

    Vector2 b_pos = new Vector2(behaviour.x_.floorToDouble(), behaviour.y_.floorToDouble());

    if (b_pos.x != x)
    {
      if (b_pos.x > x)
      {
        behaviour.walk(Directions.LEFT);
      }
      else
      {
        behaviour.walk(Directions.RIGHT);
      }
    }
    else if (b_pos.y != y)
    {
      if (b_pos.y > y)
      {
        behaviour.walk(Directions.DOWN);
      }
      else
      {
        behaviour.walk(Directions.UP);
      }
    }
    else
    {
      cur_path_point_ ++;
    }
  }
}
