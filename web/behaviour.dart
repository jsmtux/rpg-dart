library behaviour;

import 'package:vector_math/vector_math.dart';
import 'dart:math' as math;

import 'game_area.dart';
import 'drawable.dart';
import 'directions.dart';
import 'portal.dart';

abstract class Behaviour
{
  void init(Drawable drawable);
  void update(GameArea area);
}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}

class TerrainBehaviour extends Behaviour
{
  List<List<int>> heights_;
  List<Vector2> obstacles_ = new List<Vector2>();
  List<Vector3> portal_positions_ = new List<Vector3>();
  Vector3 offset_;
  List<Portal> portals_ = new List<Portal>();

  TerrainBehaviour(this.heights_, this.offset_);

  void init(Drawable drawable)
  {
  }

  void update(GameArea area)
  {
  }

  void addPortal(Portal portal, List<Vector2> positions)
  {
    portals_.add(portal);
    for (Vector2 pos in positions)
    {
      portal_positions_.add(new Vector3(pos.x, pos.y, (portals_.length - 1) * 1.0));
    }
  }

  void addObstacle(Vector2 position)
  {
    int x = position.x.floor();
    int y = heights_[0].length - position.y.floor();
    obstacles_.add(new Vector2(x *1.0, y*1.0));
  }

  Portal getPortal(Vector2 position)
  {
    int x = position.x.floor();
    int y = position.y.floor();

    Portal ret;
    for (Vector3 portal in portal_positions_)
    {
      if (portal.x == x && portal.y == y)
      {
        ret = portals_[portal.z.floor()];
        break;
      }
    }

    return ret;
  }

  double getHeight(Vector2 position)
  {
    int x = position.x.floor();
    int y = heights_[0].length - position.y.floor();
    double height;
    if (x > 0 && y > 0 && heights_.length > x && heights_[y].length > y)
    {
      bool obstacle_found = false;

      for (Vector2 obstacle in obstacles_)
      {
        if (obstacle.x == x && obstacle.y == y)
        {
          obstacle_found = true;
          break;
        }
      }
      if (obstacle_found)
      {
      }
      else
      {
        height = heights_[x][y]*1.0;

        double d_x = position.x - x;
        double d_y = y - (heights_[0].length - position.y);

        if (height < 0)
        {
          if (heights_[x][y] == -2)
            {
              int a = heights_[x-1][y];
              int b = heights_[x+1][y];
              height = b * d_x + a * (1 - d_x);
            }
            else if (heights_[x][y] == -3)
            {
              int a = heights_[x][y-1];
              int c = heights_[x][y+1];
              height = a * d_y + c * (1 - d_y);
            }
            else if (heights_[x][y] < -3)
            {
              print("dx is $d_x and dy is $d_y");
            }
        }

        height = height / 5.0 + offset_.z;
      }
    }

    return height;
  }
}

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
    move(x_, y_);
  }

  void move(double x, double y)
  {
    Vector2 pos = new Vector2(x, y);
    Portal p = terrain_.getPortal(pos);
    if (p != null)
    {
      p.transport(terrain_, this);
    }
    double height = terrain_.getHeight(pos);

    if (height != null)
    {
      x_ = x;
      y_ = y;
      if (rotation_ != null)
      {
        drawable_.setRotation(rotation_);
      }
      drawable_.setPosition(new Vector3((x_ + offset_.x)*1.0, (y_ + offset_.y)*1.0, height + offset_.z));
    }
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
  Tile3dBehaviour(double x, double y, TerrainBehaviour terrain) : super(x, y, terrain);

  void init(Drawable drawable)
  {
    super.init(drawable);
    terrain_.addObstacle(new Vector2(x_, y_));
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
  SpriteBehaviour(double x, double y, TerrainBehaviour terrain) : super(x, y, terrain)
  {
    Quaternion rot = new Quaternion.identity();
    rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -100 * (math.PI / 180));
    rotation_ = rot;
    setOffset(new Vector3(-1.0, 0.0, 2.0));
  }

  void init(Drawable drawable)
  {
    super.init(drawable);
    drawable_.setTransparent(true);
    anim_drawable_ = drawable;
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
    if (cur_state_ != null)
    {
      cur_state_.update(area);
    }
  }

  double squareDistance(SpriteBehaviour sprite)
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
