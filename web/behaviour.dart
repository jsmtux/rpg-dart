library behaviour;

import 'package:vector_math/vector_math.dart';
import 'dart:math' as math;

import 'element.dart';
import 'game_state.dart';
import 'drawable.dart';
import 'directions.dart';

abstract class Behaviour
{
  void init(EngineElement parent);
  void update(GameState state);
}

double calculateVectorLength(Vector2 vec)
{
  return vec.x * vec.x + vec.y * vec.y;
}

class TerrainBehaviour extends Behaviour
{
  List<List<int>> heights_;
  List<Vector2> obstacles_ = new List<Vector2>();

  TerrainBehaviour(this.heights_);

  void init(EngineElement parent)
  {
  }

  void update(GameState state)
  {
  }

  void addObstacle(Vector2 position)
  {
    int x = position.x.floor();
    int y = heights_.length - position.y.floor();
    obstacles_.add(new Vector2(x *1.0, y*1.0));
  }

  double getHeight(Vector2 position)
  {
    int x = position.x.floor();
    int y = heights_.length - position.y.floor();
    double height;
    if (x > 0 && y > 0 && heights_.length > x && heights_[x].length > y)
    {
      bool obstacle_found = false;

      for (Vector2 obstacle in obstacles_)
      {
        if (obstacle.x == x && obstacle.y == y + 1)
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
        double d_y = y - (heights_.length - position.y);

        if (height < 0)
        {
          int a, b, c, d;
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

        height = height / 5.0;
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

  void init(EngineElement parent)
  {
    drawable_ = parent.drawable_;
    move(x_, y_);
  }

  void move(double x, double y)
  {
    double height = terrain_.getHeight(new Vector2(x, y));

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

  void setOffset(Vector3 offset)
  {
    offset_ = offset;
  }
}

class Tile3dBehaviour extends TerrainElementBehaviour
{
  Tile3dBehaviour(double x, double y, TerrainBehaviour terrain) : super(x, y, terrain);

  void init(EngineElement parent)
  {
    super.init(parent);
    //terrain_.addObstacle(new Vector2(x_, y_));
  }

  void update(GameState state)
  {
  }
}

abstract class SpriteBehaviour extends TerrainElementBehaviour
{
  SpriteBehaviour(double x, double y, TerrainBehaviour terrain) : super(x, y, terrain)
  {
    Quaternion rot = new Quaternion.identity();
    rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -100 * (math.PI / 180));
    rotation_ = rot;
    setOffset(new Vector3(-1.0, -1.0, 2.0));
  }

  void init(EngineElement parent)
  {
    super.init(parent);
    drawable_.setTransparent(true);
  }

  void hit(SpriteBehaviour sprite)
  {
  }

  double squareDistance(SpriteBehaviour sprite)
  {
    double diff_x = x_ - sprite.x_;
    double diff_y = y_ - sprite.y_;
    return diff_x * diff_x + diff_y * diff_y;
  }
}

abstract class WalkingBehaviour extends SpriteBehaviour
{
  double vel_;
  Directions dir_;
  AnimatedDrawable anim_drawable_;

  WalkingBehaviour(double x, double y, TerrainBehaviour terrain) : super(x, y, terrain);

  void init(EngineElement parent)
  {
    super.init(parent);
    anim_drawable_ = drawable_;
  }

  void walk(Directions dir)
  {
    dir_ = dir;
    switch(dir)
    {
      case Directions.UP:
        move(x_, y_+ vel_);
        anim_drawable_.SetSequence("walk_t");
        break;
      case Directions.DOWN:
        move(x_, y_- vel_);
        anim_drawable_.SetSequence("walk_b");
        break;
      case Directions.LEFT:
        move(x_- vel_, y_);
        anim_drawable_.SetSequence("walk_l");
        break;
      case Directions.RIGHT:
        move(x_+ vel_, y_);
        anim_drawable_.SetSequence("walk_r");
        break;
    }
  }
}
