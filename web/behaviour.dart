library behaviour;

import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop_html.dart';
import 'dart:math' as math;

import 'element.dart';
import 'game_state.dart';
import 'drawable.dart';
import 'camera.dart';

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
    terrain_.addObstacle(new Vector2(x_, y_));
  }

  void update(GameState state)
  {
  }
}

class Directions
{
  final _value;
  const Directions._internal(this._value);
  toString() => 'Enum.$_value';

  static const UP = const Directions._internal('UP');
  static const DOWN = const Directions._internal('DOWN');
  static const LEFT = const Directions._internal('LEFT');
  static const RIGHT = const Directions._internal('RIGHT');
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

class EnemyBehaviour extends WalkingBehaviour
{
  Keyboard keyboard_;
  int num_steps_ = 0;
  Directions walking_dir_ = Directions.UP;
  bool dead_ = false;

  EnemyBehaviour(double x, double y, TerrainBehaviour terrain, this.keyboard_) : super(x, y, terrain)
  {
    vel_ = 0.03;
  }

  void hit(SpriteBehaviour behaviour)
  {
    if(!dead_)
    {
     dead_ = true;
     anim_drawable_.SetSequence("die", 1);
    }
  }

  void update(GameState state)
  {
    if (!dead_)
    {
      if (num_steps_ > 100)
      {
        switch(walking_dir_)
        {
          case Directions.UP:
            walking_dir_ = Directions.LEFT;
            break;
          case Directions.DOWN:
            walking_dir_ = Directions.RIGHT;
            break;
          case Directions.LEFT:
            walking_dir_ = Directions.DOWN;
            break;
          case Directions.RIGHT:
            walking_dir_ = Directions.UP;
            break;
        }
        num_steps_ = 0;
      }
      num_steps_++;
      walk(walking_dir_);
    }
  }
}

class PCBehaviour extends WalkingBehaviour
{
  bool attacking_ = false;
  bool attack_pressed = false;
  Keyboard keyboard_;
  Camera camera_;

  PCBehaviour(double x, double y, TerrainBehaviour terrain, this.keyboard_, this.camera_) : super(x, y, terrain)
  {
    vel_ = 0.05;
  }

  void update(GameState state)
  {
    double vel = 0.04;
    if(attacking_ == true)
    {
      for (EngineElement element in state.elements_)
      {
        if (element.behaviour_ is EnemyBehaviour)
        {
          EnemyBehaviour enemy = element.behaviour_;
          if (enemy.squareDistance(this) < 1.0)
          {
            enemy.hit(this);
          }
        }
      }
    }
    else if(keyboard_.isDown(Keyboard.SPACE))
    {
      if (attacking_ == false)
      {
        attacking_ = true;
        switch(dir_)
        {
          case Directions.UP:
            anim_drawable_.SetSequence("stab_t");
            break;
          case Directions.LEFT:
            anim_drawable_.SetSequence("stab_l");
            break;
          case Directions.DOWN:
            anim_drawable_.SetSequence("stab_b");
            break;
          case Directions.RIGHT:
            anim_drawable_.SetSequence("stab_r");
            break;
        }
      }
    }
    else if(keyboard_.isDown(Keyboard.UP))
    {
      walk(Directions.UP);
    }
    else if(keyboard_.isDown(Keyboard.DOWN))
    {
      walk(Directions.DOWN);
    }
    else if(keyboard_.isDown(Keyboard.LEFT))
    {
      walk(Directions.LEFT);
    }
    else if(keyboard_.isDown(Keyboard.RIGHT))
    {
      walk(Directions.RIGHT);
    }
    else
    {
      if(anim_drawable_.current_sequence_name_ != null && anim_drawable_.current_sequence_name_.contains("walk"))
      {
        switch(dir_)
        {
          case Directions.UP:
            anim_drawable_.SetSequence("stand_t");
            break;
          case Directions.LEFT:
            anim_drawable_.SetSequence("stand_l");
            break;
          case Directions.DOWN:
            anim_drawable_.SetSequence("stand_b");
            break;
          case Directions.RIGHT:
            anim_drawable_.SetSequence("stand_r");
            break;
        }
      }
    }

    if (anim_drawable_.current_sequence_ == null)
    {
      attacking_ = false;
    }

    camera_.SetPos(new Vector2(-x_, -y_));
  }
}

