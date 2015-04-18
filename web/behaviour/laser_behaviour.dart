library laser_behaviour;

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import "terrain_element_behaviour.dart";

import "behaviour.dart";
import "mouse_behaviour.dart";

import "../game_area.dart";
import "../drawable.dart";

class LaserBehaviour extends SpriteBehaviour
{
  double angle_;
  double speed_;

  LaserBehaviour(this.speed_, this.angle_, double height, double x, double y, GameArea area) : super(x, y, area)
  {
    height_ = height;
  }

  void init(Drawable drawable)
  {
    drawable.setTransparent(true);
    Quaternion rot = new Quaternion.axisAngle(new Vector3(0.0, 0.0, 1.0), angle_);
    drawable.setRotation(rot);
    super.init(drawable);
    update();
  }

  void update()
  {
    Vector2 movement = new Vector2(x_, y_);
    movement += new Vector2(speed_ * math.sin(-angle_), speed_ * math.cos(-angle_));

    if(!move(movement.x, movement.y))
    {
      area_.removeElement(this);
    }
    else
    {
      for (Behaviour behaviour in area_.behaviours_)
      {
        if (behaviour is MouseBehaviour)
        {
          MouseBehaviour mouse = behaviour;
          double distance = mouse.squareDistance(this);
          print("distance is $distance");
          if (distance < 0.25)
          {
            mouse.hit(this);
            area_.removeElement(this);
          }
        }
      }
    }
  }
}