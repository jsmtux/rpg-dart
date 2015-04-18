library pc_behaviour;

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import '../camera.dart';
import '../game_state.dart';
import '../game_area.dart';
import '../input.dart';
import '../geometry_data.dart';
import '../base_geometry.dart';
import '../drawable_factory.dart';
import 'laser_behaviour.dart';
import 'terrain_element_behaviour.dart';

class PCNormalState extends DrivingBehaviourState
{
  int last_shot_ = 0;
  TexturedGeometry laser_geom_ = new TexturedGeometry(quad_vertices, quad_indices, quad_coords, "images/laser.png");
  int cadence_ = 100;
  PCNormalState(SpriteBehaviour element) : super(element, 0.01, 0.15);

  void hit(SpriteBehaviour sprite)
  {
  }

  void update()
  {
    PCBehaviour element = element_;
    Quaternion rot = new Quaternion.axisAngle(new Vector3(0.0, 0.0, 1.0), angle_);

    element.drawable_.setRotation(rot);
    if(element.input_.isDown(Input.JUMP) && element.on_ground_)
    {
      element.z_accel_ = 0.15;
    }
    if(element.input_.isDown(Input.ATTACK))
    {
      int difference = (new DateTime.now()).millisecondsSinceEpoch - last_shot_;
      if(difference > cadence_)
      {
        element.area_.addElement(element.drawable_factory_.createTexturedDrawable(laser_geom_)
            , new LaserBehaviour(0.2, angle_, element.height_ + 0.3, element.x_ + 0.1 * math.cos(angle_) + 0.7 * math.sin(-angle_)
                , element.y_ +0.1 * math.sin(angle_) + 0.7 * math.cos(-angle_), element.area_));
        last_shot_ = (new DateTime.now()).millisecondsSinceEpoch;
      }
    }
    driveDir(new Vector2(element.input_.getAxis(Input.X), element.input_.getAxis(Input.Y)));
    element.camera_.SetPos(new Vector2(-element.x_, -element.y_), -angle_);
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
  DrawableFactory drawable_factory_;

  PCNormalState normal_state_;

  PCBehaviour(double x, double y, this.drawable_factory_, GameArea area, this.input_, this.camera_, this.state_) : super(x, y, area)
  {
    normal_state_ = new PCNormalState(this);
    cur_state_ = normal_state_;
  }
}

