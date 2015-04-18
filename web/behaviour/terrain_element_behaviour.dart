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
  GameArea area_;
  Quaternion rotation_;
  Vector3 offset_ = new Vector3.zero();

  TerrainElementBehaviour(this.x_, this.y_, this.area_);

  void init(Drawable drawable)
  {
    super.init(drawable);
    setPos(x_, y_);
  }

  void setPos(double x, double y)
  {
    Vector2 pos = new Vector2(x, y);
    double height = area_.terrain_.getHeight(pos);
    if (height == null)
    {
      height = 0.0;
    }
    drawable_.setPosition(new Vector3((x_ + offset_.x +0.5)*1.0, (y_ + offset_.y +0.5)*1.0, height + offset_.z));
  }


  void setTerrain(TerrainBehaviour t)
  {
    area_.terrain_ = t;
  }

  void setOffset(Vector3 offset)
  {
    offset_ = offset;
  }
}

class Tile3dBehaviour extends TerrainElementBehaviour
{
  double height_;
  Tile3dBehaviour(double x, double y, this.height_, GameArea area) : super(x, y, area);

  void init(Drawable drawable)
  {
    super.init(drawable);
    drawable.setScale(1/2);
    area_.terrain_.addObstacle(new Vector2(x_, y_), height_);
  }

  void update()
  {
  }
}

abstract class BehaviourState
{
  SpriteBehaviour element_;

  BehaviourState(this.element_);
  void hit(SpriteBehaviour sprite);
  void update();

  void begin()
  {
  }

  void end()
  {
  }
}

abstract class DrivingBehaviourState extends BehaviourState
{
  double angle_ = 0.0;
  double vel_ = 0.0;
  double accel_;
  double max_vel_;

  DrivingBehaviourState(SpriteBehaviour element, this.accel_, this.max_vel_) : super (element);

  void driveDir(Vector2 dir)
  {
    vel_ += dir.x * accel_;

    vel_ *= 0.93;
    if(vel_ > max_vel_)
    {
      vel_ = max_vel_;
    }

    if(!element_.move(element_.x_ + vel_ * math.sin(angle_), element_.y_ - vel_ * math.cos(angle_)))
    {
      element_.move(element_.x_, element_.y_ - vel_ * math.cos(angle_));
      element_.move(element_.x_ + vel_ * math.sin(angle_), element_.y_);
      vel_ *= 0.9;
    }

    angle_ += dir.y * vel_ * 0.2;
  }
}

abstract class WalkingBehaviourState extends BehaviourState
{
  Directions dir_;
  double vel_;

  WalkingBehaviourState(SpriteBehaviour element, this.vel_) : super (element);

  void walkDir(Vector2 dir)
  {
    double angle = math.atan2(dir.y, dir.x) - math.PI / 4;
    if(angle < 0)
    {
      angle += 2*math.PI;
    }
    Vector2 movement = dir.normalized() * vel_;
    element_.move(element_.x_ + movement.y, element_.y_ - movement.x);
    if (angle < math.PI / 2)
    {
      look(Directions.RIGHT);
    }
    else if (angle < math.PI)
    {
      look(Directions.UP);
    }
    else if (angle < 3 * math.PI / 2)
    {
      look(Directions.LEFT);
    }
    else
    {
      look(Directions.DOWN);
    }
  }

  void walk(Directions dir)
  {
    look(dir);
    switch(dir)
    {
      case Directions.UP:
        element_.move(element_.x_, element_.y_+ vel_);
        break;
      case Directions.DOWN:
        element_.move(element_.x_, element_.y_- vel_);
        break;
      case Directions.LEFT:
        element_.move(element_.x_- vel_, element_.y_);
        break;
      case Directions.RIGHT:
        element_.move(element_.x_+ vel_, element_.y_);
        break;
    }
  }

  void look(Directions dir)
  {
    dir_ = dir;
    if (element_.drawable_ is AnimatedDrawable)
    {
      switch(dir)
      {
        case Directions.UP:
          element_.anim_drawable_.SetSequence("walk_t");
          break;
        case Directions.DOWN:
          element_.anim_drawable_.SetSequence("walk_b");
          break;
        case Directions.LEFT:
          element_.anim_drawable_.SetSequence("walk_l");
          break;
        case Directions.RIGHT:
          element_.anim_drawable_.SetSequence("walk_r");
          break;
      }
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

  SpriteBehaviour(double x, double y, GameArea area) : super(x, y, area)
  {
    height_ = area.terrain_.getHeight(new Vector2(x,y));
  }

  bool move(double x, double y)
  {
    bool ret = false;
    Vector2 pos = new Vector2(x, y);
    double height = area_.terrain_.getHeight(pos);

    on_ground_ = false;
    if (height != null && height < (height_ + 0.5))
    {
      Portal p = area_.terrain_.getPortal(pos);
      if (p != null)
      {
        p.transport(area_.terrain_, this);
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
      ret = true;
      drawable_.setPosition(new Vector3((x_ + offset_.x)*1.0, (y_ + offset_.y)*1.0, height_ + offset_.z));
    }
    return ret;
  }

  void init(Drawable drawable)
  {
    super.init(drawable);
    drawable.setScale(1/8);
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

  void update()
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
      cur_state_.update();
    }
  }

  double squareDistance(TerrainElementBehaviour sprite)
  {
    double diff_x = x_ - sprite.x_;
    double diff_y = y_ - sprite.y_;
    return diff_x * diff_x + diff_y * diff_y;
  }

  void setState(BehaviourState state)
  {
    cur_state_.end();
    cur_state_ = state;
    cur_state_.begin();
  }
}
