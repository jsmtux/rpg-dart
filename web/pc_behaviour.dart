library pc_behaviour;

import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';

import 'behaviour.dart';
import 'camera.dart';
import 'game_state.dart';
import 'enemy_behaviour.dart';
import 'element.dart';
import 'directions.dart';

class PCBehaviour extends WalkingBehaviour
{
  bool attacking_ = false;
  bool attack_pressed = false;
  Keyboard keyboard_;
  Camera camera_;

  PCBehaviour(double x, double y, TerrainBehaviour terrain, this.keyboard_, this.camera_) : super(x, y, terrain)
  {
    vel_ = 0.05;
  }

  void update(GameState state)
  {
    double vel = 0.04;
    if(attacking_ == true)
    {
      for (EngineElement element in state.elements_)
      {
        if (element.behaviour_ is EnemyBehaviour)
        {
          EnemyBehaviour enemy = element.behaviour_;
          if (enemy.squareDistance(this) < 1.0)
          {
            enemy.hit(this);
          }
        }
      }
    }
    else if(keyboard_.isDown(Keyboard.SPACE))
    {
      if (attacking_ == false)
      {
        attacking_ = true;
        switch(dir_)
        {
          case Directions.UP:
            anim_drawable_.SetSequence("stab_t");
            break;
          case Directions.LEFT:
            anim_drawable_.SetSequence("stab_l");
            break;
          case Directions.DOWN:
            anim_drawable_.SetSequence("stab_b");
            break;
          case Directions.RIGHT:
            anim_drawable_.SetSequence("stab_r");
            break;
        }
      }
    }
    else if(keyboard_.isDown(Keyboard.UP))
    {
      walk(Directions.UP);
    }
    else if(keyboard_.isDown(Keyboard.DOWN))
    {
      walk(Directions.DOWN);
    }
    else if(keyboard_.isDown(Keyboard.LEFT))
    {
      walk(Directions.LEFT);
    }
    else if(keyboard_.isDown(Keyboard.RIGHT))
    {
      walk(Directions.RIGHT);
    }
    else
    {
      if(anim_drawable_.current_sequence_name_ != null && anim_drawable_.current_sequence_name_.contains("walk"))
      {
        switch(dir_)
        {
          case Directions.UP:
            anim_drawable_.SetSequence("stand_t");
            break;
          case Directions.LEFT:
            anim_drawable_.SetSequence("stand_l");
            break;
          case Directions.DOWN:
            anim_drawable_.SetSequence("stand_b");
            break;
          case Directions.RIGHT:
            anim_drawable_.SetSequence("stand_r");
            break;
        }
      }
    }

    if (anim_drawable_.current_sequence_ == null)
    {
      attacking_ = false;
    }

    camera_.SetPos(new Vector2(-x_, -y_));
  }
}

