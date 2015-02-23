library enemy_behaviour;

import 'behaviour.dart';
import 'game_state.dart';
import 'path_follower.dart';
import 'path.dart';
import 'element.dart';
import 'pc_behaviour.dart';
import 'directions.dart';

class EnemyNormalState extends WalkingBehaviourState
{
  PathFollower path_follower_;
  
  EnemyNormalState(SpriteBehaviour element, Path path) : super(element, 0.03)
  {
    path_follower_ = new MapPathFollower(path);
  }

  void hit(SpriteBehaviour sprite)
  {
    EnemyBehaviour element = element_;
    element_.setState(element.dead_state_);
  }

  void update(GameState state)
  {
    bool walking = true;
    EnemyBehaviour this_element = element_;
    for (EngineElement element in state.elements_)
    {
      if (element.behaviour_ is PCBehaviour)
      {
        PCBehaviour enemy = element.behaviour_;
        double dist = enemy.squareDistance(this_element); 
        SpriteFollower sprite_follower = path_follower_;
        if (dist < 2 && (sprite_follower.canAttack()))
        {
          walking = false;
          switch(sprite_follower.getOrientation())
          {
            case Directions.UP:
              this_element.anim_drawable_.SetSequence("stab_t");
              break;
            case Directions.DOWN:
              this_element.anim_drawable_.SetSequence("stab_b");
              break;
            case Directions.LEFT:
              this_element.anim_drawable_.SetSequence("stab_l");
              break;
            case Directions.RIGHT:
              this_element.anim_drawable_.SetSequence("stab_r");
              break;
          }
          if (this_element.anim_drawable_.current_in_sequence_ == 4)
          {
            enemy.hit(this_element);
          }
        }
        else if (dist < 16.0 && !(path_follower_ is SpriteFollower))
        {
          path_follower_ = new SpriteFollower(enemy);
        }
      }
    }
    if (walking)
    {
      path_follower_.updateWalk(this);
    }
  }
}

class EnemyDeadState extends BehaviourState
{  
  EnemyDeadState(SpriteBehaviour element) : super(element);
  
  void begin()
  {
    EnemyBehaviour element = element_;
    element_.anim_drawable_.SetSequence("die", 1);
  }
  
  void hit(SpriteBehaviour sprite)
  {
  }
  
  void update(GameState state)
  { 
  }
}

class EnemyBehaviour extends SpriteBehaviour
{
  bool dead_ = false;
  EnemyDeadState dead_state_;
  EnemyNormalState normal_state_;

  EnemyBehaviour(TerrainBehaviour terrain, Path path) 
    : super(path.position.x.floorToDouble(), path.position.y.floorToDouble(), terrain)
  {
    dead_state_ = new EnemyDeadState(this);
    normal_state_ = new EnemyNormalState(this, path);
    cur_state_ = normal_state_;
  }
}