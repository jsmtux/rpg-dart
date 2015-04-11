library sign_behaviour;

import "terrain_element_behaviour.dart";
import "terrain_behaviour.dart";
import "behaviour.dart";
import "pc_behaviour.dart";

import "../game_area.dart";
import "../dialogue_box.dart";

class SignBehaviour extends Tile3dBehaviour
{
  TextOutput text_output_;
  String text_;
  bool set_ = false;

  SignBehaviour(double x, double y, TerrainBehaviour terrain, this.text_, this.text_output_) : super(x, y, terrain);

  void update(GameArea area)
  {
    for (Behaviour behaviour in area.behaviours_)
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
            text_output_.setText("Sing has set text!");
            text_output_.setVisible(true);
            set_ = true;
          }
        }
      }
    }
  }
}
