library sheep_behaviour;

import 'package:vector_math/vector_math.dart';
import 'dart:math' as Math;

import '../game_area.dart';
import 'terrain_element_behaviour.dart';

class SheepNormalState extends WalkingBehaviourState
{
  SheepBehaviour element_;
  Math.Random rng = new Math.Random();
  int wait_time_ = 0;
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
  }

  void update()
  {
    if(random_position_ == null)
    {
      if(wait_time_ == 300)
      {
        random_position_ = new Vector2(rng.nextDouble()/10, rng.nextDouble()/10);
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
    {/*
      Vector2 diff = relative_position_ - random_position_;
      if (diff.x.abs() < 0.001 && diff.y.abs() < 0.001)
      {
        random_position_ = null;
      }
      else
      {
        Vector2 diff = (random_position_ - walk_initial_position_)/100.0;
        move(relative_position_ + diff);
      }*/
    }
  }
}

class SheepBehaviour extends SpriteBehaviour
{
  SheepNormalState normal_state_;

  SheepBehaviour(Vector2 position, GameArea area) : super(position, area)
  {
    normal_state_ = new SheepNormalState(this);
  }
}

