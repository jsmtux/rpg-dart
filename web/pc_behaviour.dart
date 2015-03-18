library pc_behaviour;

import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';

import 'behaviour.dart';
import 'camera.dart';
import 'game_state.dart';
import 'enemy_behaviour.dart';
import 'directions.dart';

class PCNormalState extends WalkingBehaviourState
{
  PCNormalState(SpriteBehaviour element) : super(element, 0.05);

  void hit(SpriteBehaviour sprite)
  {
    PCBehaviour element = element_;
    element.setState(element.dead_state_);
  }

  void update(GameState state)
  {
    PCBehaviour element = element_;
    if(element.keyboard_.isDown(Keyboard.SPACE))
    {
      element.attacking_state_.dir_ = dir_;
      element.setState(element.attacking_state_);
    }
    else if(element.keyboard_.isDown(Keyboard.UP))
    {
      walk(Directions.UP);
    }
    else if(element.keyboard_.isDown(Keyboard.DOWN))
    {
      walk(Directions.DOWN);
    }
    else if(element.keyboard_.isDown(Keyboard.LEFT))
    {
      walk(Directions.LEFT);
    }
    else if(element.keyboard_.isDown(Keyboard.RIGHT))
    {
      walk(Directions.RIGHT);
    }
    else
    {
      switch(dir_)
      {
        case Directions.UP:
          element.anim_drawable_.SetSequence("stand_t");
          break;
        case Directions.LEFT:
          element.anim_drawable_.SetSequence("stand_l");
          break;
        case Directions.DOWN:
          element.anim_drawable_.SetSequence("stand_b");
          break;
        case Directions.RIGHT:
          element.anim_drawable_.SetSequence("stand_r");
          break;
      }
    }

    element.camera_.SetPos(new Vector2(-element.x_, -element.y_));
  }
}

class PCAttackingState extends WalkingBehaviourState
{
  PCAttackingState(SpriteBehaviour element) : super(element, 0.0);

  void begin()
  {
    PCBehaviour this_element = element_;
    switch(dir_)
    {
      case Directions.UP:
        this_element.anim_drawable_.SetSequence("stab_t");
        break;
      case Directions.LEFT:
        this_element.anim_drawable_.SetSequence("stab_l");
        break;
      case Directions.DOWN:
        this_element.anim_drawable_.SetSequence("stab_b");
        break;
      case Directions.RIGHT:
        this_element.anim_drawable_.SetSequence("stab_r");
        break;
    }
  }

  void hit(SpriteBehaviour sprite)
  {
    PCBehaviour element = element_;
    element.setState(element.dead_state_);
  }

  void update(GameState state)
  {
    PCBehaviour this_element = element_;
    for (Behaviour behaviour in state.behaviours_)
    {
      if (behaviour is EnemyBehaviour)
      {
        EnemyBehaviour enemy = behaviour;
        if (enemy.squareDistance(this_element) < 1.0)
        {
          enemy.hit(this_element);
        }
      }
    }
    if (this_element.anim_drawable_.current_sequence_ == null)
    {
      this_element.setState(this_element.normal_state_);
    }
  }
}

class PCDeadState extends BehaviourState
{
  PCDeadState(SpriteBehaviour element) : super(element);

  void begin()
  {
    PCBehaviour element = element_;
    element.anim_drawable_.SetSequence("die", 1);
  }

  void hit(SpriteBehaviour sprite)
  {
  }
  void update(GameState state)
  {
  }
}

class PCBehaviour extends SpriteBehaviour
{
  bool attacking_ = false;
  bool attack_pressed = false;
  Keyboard keyboard_;
  Camera camera_;
  bool dead_ = false;

  PCNormalState normal_state_;
  PCAttackingState attacking_state_;
  PCDeadState dead_state_;

  PCBehaviour(double x, double y, TerrainBehaviour terrain, this.keyboard_, this.camera_) : super(x, y, terrain)
  {
    normal_state_ = new PCNormalState(this);
    attacking_state_ = new PCAttackingState(this);
    dead_state_ = new PCDeadState(this);
    cur_state_ = normal_state_;
  }
}

