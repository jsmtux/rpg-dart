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

  TerrainBehaviour(this.heights_);

  void init(EngineElement parent)
  {
  }
  void update(GameState state)
  {
  }

  double getHeight(Vector2 position)
  {
    int x = position.x.floor();
    int y = heights_.length - position.y.floor();
    double height = heights_[x][y]*1.0;

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

    return height;
  }
}

abstract class TerrainElementBehaviour extends Behaviour
{
  double x_, y_, z_ = 0.0;
  Drawable drawable_;
  TerrainBehaviour terrain_;
  Quaternion rotation_;

  TerrainElementBehaviour(this.x_, this.y_, this.terrain_);

  void init(EngineElement parent)
  {
    drawable_ = parent.drawable_;
    move(x_, y_);
  }

  void move(double x, double y)
  {
    x_ = x;
    y_ = y;
    double height = terrain_.getHeight(new Vector2(x, y));

    if (rotation_ != null)
    {
      drawable_.setRotation(rotation_);
    }
    drawable_.setPosition(new Vector3(x_*1.0, y_*1.0, height + z_));
  }
}

class Tile3dBehaviour extends TerrainElementBehaviour
{
  Tile3dBehaviour(double x, double y, TerrainBehaviour terrain) : super(x, y, terrain);

  void update(GameState state)
  {
  }
}

class PCBehaviour extends TerrainElementBehaviour
{
  AnimatedDrawable anim_drawable_;

  PCBehaviour(double x, double y, TerrainBehaviour terrain, this.keyboard_, this.camera_) : super(x, y, terrain)
  {
    Quaternion rot = new Quaternion.identity();
    rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -100 * (math.PI / 180));
    rotation_ = rot;
    z_ = 2.0;
  }

  void init(EngineElement parent)
  {
    super.init(parent);
    anim_drawable_ = drawable_;
  }

  Keyboard keyboard_;
  Camera camera_;

  void update(GameState state)
  {
    double vel = 0.05;
    if(keyboard_.isDown(Keyboard.UP))
    {
      move(x_, y_+ vel);
      anim_drawable_.SetSequence("walk_t");
    }
    else if(keyboard_.isDown(Keyboard.DOWN))
    {
      move(x_, y_- vel);
      anim_drawable_.SetSequence("walk_b");
    }
    else if(keyboard_.isDown(Keyboard.LEFT))
    {
      move(x_- vel, y_);
      anim_drawable_.SetSequence("walk_l");
    }
    else if(keyboard_.isDown(Keyboard.RIGHT))
    {
      move(x_+ vel, y_);
      anim_drawable_.SetSequence("walk_r");
    }
    else
    {
      anim_drawable_.SetSequence("");
    }

    camera_.SetPos(new Vector2(-x_, -y_));
  }
}

