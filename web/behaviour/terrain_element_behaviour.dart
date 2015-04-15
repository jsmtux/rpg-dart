library terrain_element_behaviour;

import 'behaviour.dart';
import 'terrain_behaviour.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math' as math;

import '../portal.dart';
import '../drawable.dart';
import '../game_area.dart';
import 'directions.dart';

abstract class TerrainElementBehaviour extends Behaviour
{
  double x_, y_= 0.0;
  Drawable drawable_;
  TerrainBehaviour terrain_;
  Quaternion rotation_;
  Vector3 offset_ = new Vector3.zero();

  TerrainElementBehaviour(this.x_, this.y_, this.terrain_);

  void init(Drawable drawable)
  {
    drawable_ = drawable;
    setPos(x_, y_);
  }

  void setPos(double x, double y)
  {
    Vector2 pos = new Vector2(x, y);
    double height = terrain_.getHeight(pos);
    drawable_.setPosition(new Vector3((x_ + offset_.x)*1.0, (y_ + offset_.y)*1.0, height + offset_.z));
  }


  void setTerrain(TerrainBehaviour t)
  {
    terrain_ = t;
  }

  void setOffset(Vector3 offset)
  {
    offset_ = offset;
  }
}

class Tile3dBehaviour extends TerrainElementBehaviour
{
  double height_;
  Tile3dBehaviour(double x, double y, this.height_, TerrainBehaviour terrain) : super(x, y, terrain);

  void init(Drawable drawable)
  {
    super.init(drawable);
    drawable.setScale(1/3);
    terrain_.addObstacle(new Vector2(x_, y_), height_);
  }

  void update(GameArea area)
  {
  }
}

abstract class BehaviourState
{
  SpriteBehaviour element_;

  BehaviourState(this.element_);
  void hit(SpriteBehaviour sprite);
  void update(GameArea area);

  void begin()
  {
  }

  void end()
  {
  }
}

abstract class WalkingBehaviourState extends BehaviourState
{
  Directions dir_;
  double vel_;

  WalkingBehaviourState(SpriteBehaviour element, this.vel_) : super (element);

  void walk(Directions dir)
  {
    dir_ = dir;
    switch(dir)
    {
      case Directions.UP:
        element_.move(element_.x_, element_.y_+ vel_);
        element_.anim_drawable_.SetSequence("walk_t");
        break;
      case Directions.DOWN:
        element_.move(element_.x_, element_.y_- vel_);
        element_.anim_drawable_.SetSequence("walk_b");
        break;
      case Directions.LEFT:
        element_.move(element_.x_- vel_, element_.y_);
        element_.anim_drawable_.SetSequence("walk_l");
        break;
      case Directions.RIGHT:
        element_.move(element_.x_+ vel_, element_.y_);
        element_.anim_drawable_.SetSequence("walk_r");
        break;
    }
  }
}

abstract class SpriteBehaviour extends TerrainElementBehaviour
{
  BehaviourState cur_state_ = null;
  AnimatedDrawable anim_drawable_;
  static const double gravity = -0.1;
  double z_accel_ = gravity;
  double height_;
  bool on_ground_ = true;

  SpriteBehaviour(double x, double y, TerrainBehaviour terrain) : super(x, y, terrain)
  {
    height_ = terrain.getHeight(new Vector2(x,y));
    Quaternion rot = new Quaternion.identity();
    rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -100 * (math.PI / 180));
    rotation_ = rot;
    setOffset(new Vector3(-1.0, 0.0, 2.0));
  }

  void move(double x, double y)
  {
    Vector2 pos = new Vector2(x, y);
    double height = terrain_.getHeight(pos);

    on_ground_ = false;
    if (height != null && height < (height_ + 0.5))
    {
      Portal p = terrain_.getPortal(pos);
      if (p != null)
      {
        p.transport(terrain_, this);
      }
      x_ = x;
      y_ = y;
      if (rotation_ != null)
      {
        drawable_.setRotation(rotation_);
      }
      if (height_ == null)
      {
        height_ = height;
      }
      else
      {
        if(height_ <= height)
        {
          on_ground_ = true;
          height_ = height;
        }
      }
      drawable_.setPosition(new Vector3((x_ + offset_.x)*1.0, (y_ + offset_.y)*1.0, height_ + offset_.z));
    }
  }

  void init(Drawable drawable)
  {
    super.init(drawable);
    drawable_.setTransparent(true);
    if (drawable is AnimatedDrawable)
    {
      anim_drawable_ = drawable;
    }
  }

  void hit(SpriteBehaviour sprite)
  {
    if (cur_state_ != null)
    {
      cur_state_.hit(sprite);
    }
  }

  void update(GameArea area)
  {
    z_accel_ -= 0.01;
    if (z_accel_ < gravity)
    {
      z_accel_ = gravity;
    }
    height_ += z_accel_;
    move(x_, y_);
    if (cur_state_ != null)
    {
      cur_state_.update(area);
    }
  }

  double squareDistance(TerrainElementBehaviour sprite)
  {
    double diff_x = x_ - sprite.x_ - 0.5;
    double diff_y = y_ - sprite.y_ - 0.5;
    return diff_x * diff_x + diff_y * diff_y;
  }

  void setState(BehaviourState state)
  {
    cur_state_.end();
    cur_state_ = state;
    cur_state_.begin();
  }
}
