library mouse_behaviour;

import "terrain_element_behaviour.dart";
import "behaviour.dart";
import "pc_behaviour.dart";
import "laser_behaviour.dart";
import 'path_follower.dart';

import "../game_area.dart";

class MouseNormalState extends WalkingBehaviourState
{

  MouseNormalState(MouseBehaviour behaviour) : super(behaviour, 0.05);

  void hit(SpriteBehaviour sprite)
  {
    if(sprite is LaserBehaviour)
    {
      print("hit!");
      element_.area_.removeElement(element_);
    }
  }

  void update()
  {
    for (Behaviour behaviour in element_.area_.behaviours_)
    {
      if (behaviour is PCBehaviour)
      {
        if (behaviour.squareDistance(element_) < 1)
        {
          element_.cur_state_ = new MouseFollowState(element_, behaviour);
        }
      }
    }
  }
}

class MouseFollowState extends WalkingBehaviourState
{
  SpriteFollower sprite_follower_;
  PCBehaviour pc_;

  MouseFollowState(MouseBehaviour behaviour, this.pc_) : super(behaviour, 0.05)
  {
    sprite_follower_ = new SpriteFollower(pc_);
  }

  void hit(SpriteBehaviour sprite)
  {
    if(sprite is LaserBehaviour)
    {
      print("hit!");
      element_.area_.removeElement(element_);
    }
  }

  void update()
  {
    sprite_follower_.updateWalk(this);
    if (pc_.squareDistance(element_) > 6)
    {
      element_.cur_state_ = new MouseNormalState(element_);
    }
  }
}

class MouseBehaviour extends SpriteBehaviour
{
  bool dead_ = false;

  MouseNormalState normal_state_;

  MouseBehaviour(double x, double y, GameArea area) : super(x, y, area)
  {
    normal_state_ = new MouseNormalState(this);
    cur_state_ = normal_state_;
  }
}
