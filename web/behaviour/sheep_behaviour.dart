library sheep_behaviour;

import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;

import '../game_area.dart';
import 'terrain_element_behaviour.dart';
import 'pc_behaviour.dart';

abstract class Followable implements SpriteBehaviour
{
  Followable getFollower();
  void setFollower(SpriteBehaviour follower);
}

class SheepNormalState extends WalkingBehaviourState
{
  SheepBehaviour element_;
  Math.Random rng = new Math.Random();
  int wait_time_ = 300;
  Vector2 random_position_;
  Vector2 initial_position_;
  Vector2 walk_initial_position_ = new Vector2(0.0,0.0);

  SheepNormalState(SpriteBehaviour element) : super(element, 0.05)
  {
    element_ = element;
    initial_position_ = element_.position_;
    rng.nextInt(300);
  }

  void hit(SpriteBehaviour sprite)
  {
    Followable toFollow;

    if (sprite is SheepBehaviour)
    {
      toFollow = sprite;
    }
    if (sprite is PCBehaviour)
    {
      toFollow = sprite;
    }

    while (toFollow.getFollower() != null)
    {
      toFollow = toFollow.getFollower();
    }

    toFollow.setFollower(element_);
    element_.setState(new SheepFollowerBehaviour(element_, toFollow));
  }

  void update()
  {
    if(random_position_ == null)
    {
      if(wait_time_ == 300)
      {
        random_position_ = new Vector2(rng.nextDouble()/2, rng.nextDouble()/2);
        random_position_ = initial_position_ + random_position_;
        walk_initial_position_ = element_.position_;
        wait_time_ = rng.nextInt(150);
      }
      else
      {
        wait_time_ = wait_time_ + 1;
      }
    }
    else
    {
      Vector2 diff = element_.position_ - random_position_;
      if (diff.x.abs() < 0.001 && diff.y.abs() < 0.001)
      {
        random_position_ = null;
      }
      else
      {
        Vector2 diff = (random_position_ - walk_initial_position_)/100.0;
        element_.move(element_.position_ + diff);
      }
    }
  }
}

class SheepFollowerBehaviour extends WalkingBehaviourState
{
  SpriteBehaviour follow_;

  SheepFollowerBehaviour(SpriteBehaviour element, this.follow_) : super(element, 0.05)
  {
    element_ = element;
  }

  void hit(SpriteBehaviour sprite)
  {
  }

  void update()
  {
    if (follow_.squareDistance(element_) > 1)
    {
      Vector2 diff = (follow_.position_ - element_.position_).normalize();
      walkDir(diff);
    }
  }
}

class SheepBehaviour extends SpriteBehaviour implements Followable
{
  SheepNormalState normal_state_;
  SheepBehaviour follower_;

  SheepBehaviour(Vector2 position, GameArea area) : super(position, area)
  {
    normal_state_ = new SheepNormalState(this);
    cur_state_ = normal_state_;
  }

  bool isFollowing()
  {
    return cur_state_ is SheepFollowerBehaviour;
  }

  Followable getFollower()
  {
    return follower_;
  }

  void setFollower(SpriteBehaviour follower)
  {
    if (follower_ == null)
    {
      follower_ = follower;
    }
  }
}

