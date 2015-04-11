library portal;

import 'game_area.dart';
import 'game_state.dart';
import 'behaviour/terrain_behaviour.dart';
import 'behaviour/terrain_element_behaviour.dart';

class Portal
{
  String map_name_;
  List<String> areas_hide_;
  List<String> areas_show_;
  GameState state_;

  Portal(this.map_name_, this.state_);

  void transport(TerrainBehaviour terrain, TerrainElementBehaviour element)
  {
    GameArea area = state_.areas_[map_name_];
    if (area == null)
    {
      print("Game area $map_name_ not found for portal");
    }
    else
    {
      element.terrain_ = area.terrain_;
      state_.setVisible(map_name_, true);
      for (String area in areas_hide_)
      {
        state_.setVisible(area, false);
      }
      for (String area in areas_show_)
      {
        state_.setVisible(area, true);
      }
    }
  }
}