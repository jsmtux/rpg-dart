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
  Vector2 position_ = new Vector2.zero();
  GameArea area_;
  Quaternion rotation_;
  Vector3 offset_ = new Vector3.zero();

  TerrainElementBehaviour(this.position_, this.area_);

  double squareDistance(TerrainElementBehaviour sprite)
  {
    return (position_ + offset_.xy).distanceToSquared(sprite.position_ + sprite.offset_.xy);
  }

  void init(Drawable drawable)
  {
    super.init(drawable);
    double height = area_.terrain_.getHeight(position_);
    if (height == null)
    {
      height = 0.0;
    }
    drawable_.setPosition(new Vector3((position_.x + offset_.x)*1.0, (position_.y + offset_.y)*1.0, height + offset_.z));
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
  Tile3dBehaviour(Vector2 position, this.height_, GameArea area) : super(position, area);

  void init(Drawable drawable)
  {
    super.init(drawable);
    drawable.setScale(1/3);
    drawable.move(new Vector3(0.5,0.5,0.0));
    area_.terrain_.addObstacle(position_ + new Vector2(0.5,0.5), this);
  }

  double getHeight()
  {
    return height_;
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

abstract class WalkingBehaviourState extends BehaviourState
{
  Directions dir_ = Directions.UP;
  double vel_;

  WalkingBehaviourState(SpriteBehaviour element, this.vel_) : super (element);

  void walkDir(Vector2 dir)
  {
    Vector2 movement = dir.normalized() * vel_;
    if(element_.move(element_.position_ + movement))
    {
    }
    else if (element_.move(element_.position_ + new Vector2(movement.x, 0.0)))
    {

    }
    else
    {
      element_.move(element_.position_ + new Vector2(0.0, movement.y));
    }

    double angle = math.atan2(dir.y, dir.x) - math.PI / 4;
    if(angle < 0)
    {
      angle += 2*math.PI;
    }
    if (angle < math.PI / 2)
    {
      look(Directions.UP);
    }
    else if (angle < math.PI)
    {
      look(Directions.LEFT);
    }
    else if (angle < 3 * math.PI / 2)
    {
      look(Directions.DOWN);
    }
    else
    {
      look(Directions.RIGHT);
    }
  }

  void walk(Directions dir)
  {
    look(dir);
    switch(dir)
    {
      case Directions.UP:
        element_.move(element_.position_ + new Vector2(0.0 , vel_));
        break;
      case Directions.DOWN:
        element_.move(element_.position_ + new Vector2(0.0 , -vel_));
        break;
      case Directions.LEFT:
        element_.move(element_.position_ + new Vector2(-vel_, 0.0));
        break;
      case Directions.RIGHT:
        element_.move(element_.position_ + new Vector2(vel_, 0.0));
        break;
    }
  }

  void look(Directions dir)
  {
    dir_ = dir;
    if (element_.drawable_ is AnimatedSprite)
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
  AnimatedSprite anim_drawable_;
  static const double gravity = -0.1;
  double z_accel_ = gravity;
  double height_;
  bool on_ground_ = true;

  SpriteBehaviour(Vector2 pos, GameArea area) : super(pos, area)
  {
    height_ = area.terrain_.getHeight(pos);
    Quaternion rot = new Quaternion.identity();
    rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -100 * (math.PI / 180));
    rotation_ = rot;
    setOffset(new Vector3(-0.5, 0.0, 1.0));
  }

  bool move(Vector2 pos)
  {
    bool ret = false;
    double height = area_.terrain_.getHeight(pos);

    on_ground_ = false;
    if (height != null && height < (height_ + 0.5))
    {
      Portal p = area_.terrain_.getPortal(pos);
      if (p != null)
      {
        p.transport(area_.terrain_, this);
      }
      position_ = pos;
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
      drawable_.setPosition(new Vector3((position_.x + offset_.x)*1.0, (position_.y + offset_.y)*1.0, height_ + offset_.z));
    }
    return ret;
  }

  void init(Drawable drawable)
  {
    super.init(drawable);
    drawable_.setTransparent(true);
    if (drawable is AnimatedSprite)
    {
      anim_drawable_ = drawable;
    }
    drawable_.setScale(1/2);
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
    move(position_);
    if (cur_state_ != null)
    {
      cur_state_.update();
    }
  }

  void setState(BehaviourState state)
  {
    cur_state_.end();
    cur_state_ = state;
    cur_state_.begin();
  }
}
