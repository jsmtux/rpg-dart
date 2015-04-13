library terrain_behaviour;

import 'behaviour.dart';
import 'package:vector_math/vector_math.dart';

import '../portal.dart';
import '../drawable.dart';
import '../game_area.dart';

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
    int x = position.x.floor() - offset_.x.floor();
    int y = heights_[0].length - (position.y.floor() - offset_.y.floor());
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
    int x = position.x.floor() - offset_.x.floor();
    int y = heights_[0].length - (position.y.floor() - offset_.y.floor());
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
            else if (heights_[x][y] == -4)
            {
              int b = heights_[x+1][y-1];
              int c = heights_[x-1][y+1];
              if( d_x > d_y)
              {
                height = b * d_y + c * (1 - d_y);
              }
              else
              {
                height = b * d_x + c * (1 - d_x);
              }
            }
            else if (heights_[x][y] == -5)
            {
              int a = heights_[x-1][y-1];
              int d = heights_[x+1][y+1];
              if( (1 - d_x) > d_y)
              {
                height = a * d_y + d * (1 - d_y);
              }
              else
              {
                height = d * d_x + a * (1 - d_x);
              }
            }
        }

        height = height / 5.0 + offset_.z;
      }
    }

    return height;
  }
}