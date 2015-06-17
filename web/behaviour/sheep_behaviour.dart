library sheep_behaviour;

import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;

import '../game_area.dart';
import 'terrain_element_behaviour.dart';
import 'pc_behaviour.dart';
import 'enemy_behaviour.dart';

abstract class Followable implements SpriteBehaviour
{
  Followable getFollower();
  void setFollower(SpriteBehaviour follower);
}

abstract class Follower implements Followable
{
  void stopFollowing();
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
    if (sprite is EnemyBehaviour)
    {
      element_.setState(new SheepDeadState(element_));
    }
    else
    {
      Followable toFollow;

      if (sprite is PCBehaviour)
      {
        toFollow = sprite;
      }

      while (toFollow.getFollower() != null)
      {
        toFollow = toFollow.getFollower();
      }

      toFollow.setFollower(element_);
      element_.setState(new SheepFollowerState(element_, toFollow));
    }
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

class SheepFollowerState extends WalkingBehaviourState
{
  Followable follow_;

  SheepFollowerState(SpriteBehaviour element, this.follow_) : super(element, 0.05)
  {
    element_ = element;
  }

  void hit(SpriteBehaviour sprite)
  {
    if (sprite is EnemyBehaviour)
    {
      SheepBehaviour element = element_;
      follow_.setFollower(null);
      if (element.follower_ != null)
      {
        element.follower_.stopFollowing();
      }
      element_.setState(new SheepDeadState(element_));
    }
  }

  void update()
  {
    if (follow_.squareDistance(element_) > 2)
    {
      Vector2 diff = (follow_.position_ - element_.position_).normalize();
      walkDir(diff);
    }
  }
}

class SheepDeadState extends BehaviourState
{
  SheepDeadState(SpriteBehaviour element) : super(element);

  void begin()
  {
  }

  void hit(SpriteBehaviour sprite)
  {
  }

  void update()
  {
  }
}

class SheepBehaviour extends SpriteBehaviour implements Follower
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
    return cur_state_ is SheepFollowerState;
  }

  bool isDead()
  {
    return cur_state_ is SheepDeadState;
  }

  Followable getFollower()
  {
    return follower_;
  }

  void stopFollowing()
  {
    if (cur_state_ is SheepFollowerState)
    {
      setState(new SheepNormalState(this));
      if (follower_ != null)
      {
        follower_.stopFollowing();
        follower_ = null;
      }
    }
  }

  void setFollower(SpriteBehaviour follower)
  {
    if (follower_ == null)
    {
      follower_ = follower;
    }
  }
}

