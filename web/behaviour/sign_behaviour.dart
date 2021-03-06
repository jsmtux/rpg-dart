library sign_behaviour;

import 'package:vector_math/vector_math.dart';

import "terrain_element_behaviour.dart";
import "behaviour.dart";
import "pc_behaviour.dart";

import "../game_area.dart";
import "../dialogue_box.dart";

class SignBehaviour extends Tile3dBehaviour
{
  TextOutput text_output_;
  String text_;
  bool set_ = false;

  SignBehaviour(Vector2 position, GameArea area, this.text_, this.text_output_) : super(position, 1.0, area);

  void update()
  {
    for (Behaviour behaviour in area_.behaviours_)
    {
      if (behaviour is PCBehaviour)
      {
        PCBehaviour pc = behaviour;
        if (set_)
        {
          if (pc.squareDistance(this) > 1.0)
          {
            text_output_.setVisible(false);
            text_output_.setText("");
            set_ = false;
          }
        }
        else
        {
          if (pc.squareDistance(this) < 1.0)
          {
            text_output_.setText(text_);
            text_output_.setVisible(true);
            set_ = true;
          }
        }
      }
    }
  }
}
