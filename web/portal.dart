library portal;

import 'game_area.dart';
import 'game_state.dart';
import 'behaviour.dart';

class Portal
{
  String map_name_;
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
    }
  }
}