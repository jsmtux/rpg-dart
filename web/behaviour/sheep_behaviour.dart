library sheep_behaviour;

import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;

import '../game_area.dart';
import 'terrain_element_behaviour.dart';
import 'pc_behaviour.dart';
import 'enemy_behaviour.dart';
import 'behaviour.dart';
import 'grass_behaviour.dart';

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
  BaseSheepBehaviour element_;
  Math.Random rng = new Math.Random();
  int wait_time_;
  Vector2 random_position_;
  Vector2 initial_position_;
  Vector2 walk_initial_position_ = new Vector2(0.0,0.0);

  SheepNormalState(SpriteBehaviour element) : super(element, 0.01)
  {
    element_ = element;
    initial_position_ = element_.position_;
    wait_time_ = rng.nextInt(300);
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
        if (element_.checkWillFollow(sprite))
        {
          toFollow = sprite;
        }
      }

      while (toFollow != null && toFollow.getFollower() != null)
      {
        toFollow = toFollow.getFollower();
      }

      if (toFollow != null)
      {
        toFollow.setFollower(element_);
        element_.setState(new SheepFollowerState(element_, toFollow));
      }
    }
  }

  void randomWalk()
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
        Vector2 diff = (random_position_ - walk_initial_position_)/500.0;
        element_.move(element_.position_ + diff);
      }
    }
  }

  void update()
  {
    bool updated = false;
    for (Behaviour behaviour in element_.area_.behaviours_)
    {
      double min_distance;
      GrassBehaviour closest_grass;
      if (behaviour is GrassBehaviour)
      {
        double dist = element_.squareDistance(behaviour);
        if (min_distance == null || dist < min_distance)
        {
          min_distance = dist;
          closest_grass = behaviour;
        }
      }
      if (closest_grass != null)
      {
        if (min_distance < 0.05)
        {
          updated = true;
          break;
        }
        else if (min_distance < 1)
        {
          Vector2 diff = (closest_grass.position_ - element_.position_).normalize();
          walkDir(diff);
          updated = true;
          break;
        }
      }
    }
    if (!updated)
    {
      randomWalk();
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
      BaseSheepBehaviour element = element_;
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
    if (follow_.squareDistance(element_) > 0.8)
    {
      /*if (follow_.squareDistance(element_) > 10)
      {
        follow_.setFollower(null);
        BaseSheepBehaviour element = element_;
        if (element.follower_ != null)
        {
          element.follower_.stopFollowing();
        }
        element.setState(new SheepNormalState(element));
      }
      else*/
      {
        Vector2 diff = (follow_.position_ - element_.position_).normalize();
        walkDir(diff);
      }
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

abstract class BaseSheepBehaviour extends SpriteBehaviour implements Follower
{
  BaseSheepBehaviour follower_;

  BaseSheepBehaviour(Vector2 position, GameArea area) : super(position, area)
  {
    cur_state_ = new SheepNormalState(this);
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

  bool checkWillFollow(PCBehaviour pc);

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
    follower_ = follower;
  }
}

class SheepBehaviour extends BaseSheepBehaviour
{
  SheepBehaviour(Vector2 position, GameArea area) : super(position, area)
  {
  }

  bool checkWillFollow(PCBehaviour pc)
  {
    return true;
  }
}

class GoldSheepBehaviour extends BaseSheepBehaviour
{
  GoldSheepBehaviour(Vector2 position, GameArea area) : super(position, area)
  {
  }

  bool checkWillFollow(PCBehaviour pc)
  {
    int num_sheep = 0;
    Followable tmp_follower = pc;

    while((tmp_follower = tmp_follower.getFollower()) != null)
    {
      num_sheep++;
    }
    return num_sheep >= 2;
  }
}

