library pc_behaviour;

import 'package:vector_math/vector_math.dart';

import '../camera.dart';
import '../game_state.dart';
import '../game_area.dart';
import '../input.dart';
import '../shader_properties.dart';
import 'behaviour.dart';
import 'enemy_behaviour.dart';
import 'directions.dart';
import 'terrain_element_behaviour.dart';

class PCNormalState extends WalkingBehaviourState
{
  PCNormalState(SpriteBehaviour element) : super(element, 0.05);

  void hit(SpriteBehaviour sprite)
  {
    PCBehaviour element = element_;
    element.setState(element.dead_state_);
  }

  void update()
  {
    PCBehaviour element = element_;
    var shader = element.state_.renderer_.light_shader_;
    LightingShaderProperty lighting_property = shader.getShaderProperty(LightingShaderProperty.propName);
    lighting_property.setPointLightPos(element.drawable_.getPosition());
    if(element.input_.isDown(Input.JUMP) && element.on_ground_)
    {
      element.z_accel_ = 0.15;
    }
    if(element.input_.isDown(Input.ATTACK))
    {
      element.attacking_state_.dir_ = dir_;
      element.setState(element.attacking_state_);
    }
    else if(element.input_.getAxis(Input.X) != 0 || element.input_.getAxis(Input.Y) != 0 )
    {
      walkDir(new Vector2(element.input_.getAxis(Input.X), element.input_.getAxis(Input.Y)));
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

  void update()
  {
    PCBehaviour this_element = element_;
    for (Behaviour behaviour in element_.area_.behaviours_)
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
  void update()
  {
  }
}

class PCBehaviour extends SpriteBehaviour
{
  bool attacking_ = false;
  bool attack_pressed = false;
  Input input_;
  Camera camera_;
  bool dead_ = false;
  GameState state_;

  PCNormalState normal_state_;
  PCAttackingState attacking_state_;
  PCDeadState dead_state_;

  PCBehaviour(double x, double y, GameArea area, this.input_, this.camera_, this.state_) : super(x, y, area)
  {
    normal_state_ = new PCNormalState(this);
    attacking_state_ = new PCAttackingState(this);
    dead_state_ = new PCDeadState(this);
    cur_state_ = normal_state_;
  }
}

