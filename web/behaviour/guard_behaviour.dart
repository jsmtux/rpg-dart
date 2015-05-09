library guard_behaviour;

import 'package:vector_math/vector_math.dart';

import '../game_area.dart';
import "../dialogue_box.dart";

import 'terrain_element_behaviour.dart';
import "behaviour.dart";
import "pc_behaviour.dart";

class GuardNormalState extends WalkingBehaviourState
{
  bool set_ = false;
  GuardNormalState(SpriteBehaviour element) : super(element, 0.03)
  {
  }

  void hit(SpriteBehaviour sprite)
  {
  }

  void update()
  {
    GuardBehaviour guard_element_ = element_;
    for (Behaviour behaviour in element_.area_.behaviours_)
    {
      if (behaviour is PCBehaviour)
      {
        PCBehaviour pc = behaviour;
        if (set_)
        {
          if (pc.squareDistance(element_) > 1.0)
          {
            guard_element_.text_output_.setVisible(false);
            guard_element_.text_output_.setText("");
            set_ = false;
          }
        }
        else
        {
          if (pc.squareDistance(element_) < 1.0)
          {
            guard_element_.text_output_.setText("You don't look like a Soldier");
            guard_element_.text_output_.setVisible(true);
            set_ = true;
          }
        }
      }
    }
  }
}

class GuardBehaviour extends SpriteBehaviour
{
  GuardNormalState normal_state_;
  TextOutput text_output_;

  GuardBehaviour(GameArea area, Vector2 pos, this.text_output_)
    : super(pos.x, pos.y, area)
  {
    normal_state_ = new GuardNormalState(this);
    cur_state_ = normal_state_;
  }
}