library path_follower;

import 'package:vector_math/vector_math.dart';

import 'directions.dart';
import 'terrain_element_behaviour.dart';
import '../path.dart';

abstract class PathFollower
{
  void updateWalk(WalkingBehaviourState behaviour);
  Vector2 getNextNode();
}

class SquarePathFollower implements PathFollower
{
  int num_steps_ = 0;
  Directions walking_dir_ = Directions.UP;

  void updateWalk(WalkingBehaviourState behaviour)
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

  Vector2 getNextNode()
  {
    return new Vector2.zero();
  }
}

class SpriteFollower implements PathFollower
{
  SpriteBehaviour following_;
  bool walk_horizontal_ = false;
  int same_direction_time_ = 0;
  Vector2 same_direction_pos_;
  bool same_line_ = false;
  Directions difference_ = Directions.UP;

  SpriteFollower(this.following_);

  bool canAttack()
  {
    return same_line_;
  }

  void updateWalk(WalkingBehaviourState behaviour)
  {
    Vector2 diff = behaviour.element_.position_ - following_.position_;
    double threshold = 0.2;

    same_line_ = diff.x.abs() < threshold || diff.y.abs() < threshold;

    if (same_line_ ||
        ((diff.x - diff.x.floor()).abs() < 0.1 && walk_horizontal_) ||
        ((diff.y - diff.y.floor()).abs() < 0.1 && !walk_horizontal_))
    {
      walk_horizontal_ = diff.x.abs() > diff.y.abs();
    }

    if(walk_horizontal_)
    {
      if (diff.x > threshold)
      {
        difference_ = Directions.LEFT;
      }
      else if (diff.x < -threshold)
      {
        difference_ = Directions.RIGHT;
      }
    }
    else
    {
      if (diff.y < -threshold)
      {
        difference_ = Directions.UP;
      }
      else if (diff.y > threshold)
      {
        difference_ = Directions.DOWN;
      }
    }
    behaviour.walk(difference_);
  }

  Directions getOrientation()
  {
    return difference_;
  }

  Vector2 getNextNode()
  {
    return following_.position_;
  }
}

class MapPathFollower implements PathFollower
{
  Path path_;
  int cur_path_point_ = 0;
  Function callback_;

  MapPathFollower(this.path_);

  void updateWalk(WalkingBehaviourState behaviour)
  {
    Vector2 position = path_.points[cur_path_point_];
    int x = position.x.floor();
    int y = position.y.floor();

    Vector2 b_pos = new Vector2(behaviour.element_.position_.x.floorToDouble(),
        behaviour.element_.position_.y.floorToDouble());

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

    if (cur_path_point_ >= path_.points.length)
    {
      if (callback_ == null)
      {
        cur_path_point_ = 0;
      }
      else
      {
        callback_();
      }
    }
  }

  Vector2 getNextNode()
  {
    return path_.points[cur_path_point_];
  }
}
