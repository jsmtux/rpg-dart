import "dart:math";

import 'package:vector_math/vector_math.dart';

import 'terrain_element_behaviour.dart';

import '../path.dart';

void printMap(List map)
{
  for (String line in map)
  {
    print(line + '\n');
  }
}

List<List<int>> getRealMap(List map, Vector2 ini, Vector2 end)
{
  List<List<int>> ret = new List<List<int>>();
  int ind = 0;
  for (String line in map)
  {
    ret.add(new List<int>());
    for (int i = 0; i < line.length; i++)
    {
      if (line[i] == '+')
      {
        ret.last.add(1);
      }
      else
      {
        ret.last.add(0);
        if (line[i] == 'i')
        {
          ini.x = i * 1.0;
          ini.y = ind * 1.0;
        }
        else if (line[i] == 'e')
        {
          end.x = i * 1.0;
          end.y = ind * 1.0;
        }
      }
    }
    ind++;
  }
  return ret;
}

int getScore(Vector2 pos, Vector2 end)
{
  Vector2 diff = new Vector2(pos.x - end.x, pos.y - end.y);
  return (sqrt(diff.x * diff.x + diff.y * diff.y) * 10).floor();
}

class Node
{
  Vector2 pos_;
  int f_score;
  int g_score;
  Node(this.pos_, Vector2 end, this.g_score)
  {
    f_score = getScore(pos_, end);
  }
}

bool positionInMap(Map<Vector2, Tile3dBehaviour> map, Vector2 position, Vector2 size)
{
  bool ret = false;

  map.forEach((Vector2 pos, Tile3dBehaviour t)
  {
    if (pos.x.floor() == position.x.floor() && pos.y.floor() == size.y - position.y.floor())
    {
      ret = true;
      return true;//against code standards, only way to exit foreach
    }
  });

  return ret;
}

List<Node> getNeighboors(Node current, Map<Vector2, Tile3dBehaviour> map, Vector2 size,  Vector2 end)
{
  List<Node> ret = new List<Node>();
  int short_distance = 10;
  int long_distance = 14;
  List<Vector2> near_positions = new List<Vector2>();
  near_positions.add(new Vector2(current.pos_.x + 1, current.pos_.y));
  near_positions.add(new Vector2(current.pos_.x - 1, current.pos_.y));
  near_positions.add(new Vector2(current.pos_.x, current.pos_.y + 1));
  near_positions.add(new Vector2(current.pos_.x, current.pos_.y - 1));
  /*List<Vector2> far_positions = new List<Vector2>();
  far_positions.add(new Vector2(current.pos_.x + 1, current.pos_.y + 1));
  far_positions.add(new Vector2(current.pos_.x - 1, current.pos_.y - 1));
  far_positions.add(new Vector2(current.pos_.x - 1, current.pos_.y + 1));
  far_positions.add(new Vector2(current.pos_.x + 1, current.pos_.y - 1));
*/
  for(Vector2 pos in near_positions)
  {
    if (pos.x > 0 && pos.y > 0 && pos.x < size.x && pos.y < size.y && !positionInMap(map, pos, size))
    {
      ret.add(new Node(pos, end, current.g_score + short_distance));
    }
  }
/*
  for(Vector2 pos in far_positions)
  {
    if (pos.x >= 0 && pos.y >= 0 && pos.x < size.x && pos.y < size.y && !positionInMap(map, pos, size))
    {
      ret.add(new Node(pos, end, current.g_score + long_distance));
    }
  }
*/
  return ret;
}

Path getPath(Map<Vector2, Vector2> traversed_map, Vector2 init, Vector2 end)
{
  List<Vector2> ret = new List<Vector2>();

  if (init.x == end.x && init.y == end.y)
  {
    ret.add(init);
  }
  else
  {
    ret.add(end);
    while(ret.last != init)
    {
      bool added = false;
      for(Vector2 key in traversed_map.keys)
      {
        if (key.x == ret.last.x && key.y == ret.last.y)
        {
          ret.add(traversed_map[key]);
          added = true;
          break;
        }
      }
      if (!added)
      {
        print("path is not complete!!!");
      }
    }
    List<Vector2> rev_ret = new List<Vector2>();
    for (Vector2 vec in ret.reversed)
    {
      rev_ret.add(vec);
    }
    ret = rev_ret;
  }

  return new Path("aStar", ret);
}

Path aStar(Map<Vector2, Tile3dBehaviour> map, Vector2 size, Vector2 init, Vector2 end)
{
  List<Node> closed_set = new List<Node>();
  List<Node> open_set = new List<Node>();
  Map<Vector2, Vector2> traversed_map = new Map<Vector2, Vector2>();
  init = new Vector2(init.x.floorToDouble(), init.y.floorToDouble());
  end = new Vector2(end.x.floorToDouble(), end.y.floorToDouble());
  open_set.add(new Node(init, end, 0));

  while(open_set.isNotEmpty)
  {
    Node current = open_set.last;
    if(current.pos_.x == end.x && current.pos_.y == end.y)
    {
      if (traversed_map.length == 0)
      {
        print("empty");
      }
      break;
    }
    open_set.removeLast();
    closed_set.add(current);

    //print("picked element with score ${current.f_score} at ${current.pos_.x}, ${current.pos_.y}");

    List<Node> neighboors = getNeighboors(current, map, size, end);
    //print("element has ${neighboors.length} neighbors");

    for (Node cur_neighboor in neighboors)
    {
      //print("cur neighbor pos is ${cur_neighboor.pos_.x}, ${cur_neighboor.pos_.y}");
      bool closed_contains = (closed_set.firstWhere((Node o) => o.pos_.x == cur_neighboor.pos_.x
          &&o.pos_.y == cur_neighboor.pos_.y , orElse: () => null) != null);
      if(!closed_contains)
      {
        Node equal_open_set = open_set.firstWhere((Node o) => o.pos_.x == cur_neighboor.pos_.x
            &&o.pos_.y == cur_neighboor.pos_.y , orElse: () => null);
        bool change = true;
        if (equal_open_set != null)
        {
          //print("neighbor was already in open set");
          if (equal_open_set.g_score <= cur_neighboor.g_score)
          {
            //print("not updating neighbor in open set");
            change = false;
          }
          else
          {
            //print("updating neighbor in open set");
            equal_open_set.g_score = cur_neighboor.g_score;
            equal_open_set.f_score = cur_neighboor.g_score + getScore(cur_neighboor.pos_, end);
          }
        }
        else
        {
          cur_neighboor.f_score = cur_neighboor.g_score + getScore(cur_neighboor.pos_, end);
          //print("neighbor was not in open set, setting score to ${cur_neighboor.f_score}");
          open_set.add(cur_neighboor);
        }
        if (change)
        {
          //print("${cur_neighboor.pos_.x}, ${cur_neighboor.pos_.y} <- ${current.pos_.x}, ${current.pos_.y}");
          traversed_map[cur_neighboor.pos_] = current.pos_;
        }
      }
    }

    open_set.sort((x, y){
      int ret;
      if (x.f_score > y.f_score)
      {
        ret = -1;
      }
      else if (x.f_score == y.f_score)
      {
        ret = 0;
      }
      else
      {
        ret = 1;
      }
      return ret;
    });
  }
  return getPath(traversed_map, init, end);
}
/*
void a_star_test() {
  List<String> test_map = new List<String>();
  test_map.add("i---+---");
  test_map.add("----+-+-");
  test_map.add("----+e+-");
  test_map.add("----+++-");
  test_map.add("----+---");
  test_map.add("--------");
  test_map.add("----+---");
  printMap(test_map);
  Vector2 init = new Vector2(0.0, 0.0);
  Vector2 end = new Vector2(0.0, 0.0);
  List<List<int>> map = getRealMap(test_map, init, end);
  print("astar");
  Map<Vector2, Vector2> traversed_map = aStar(map, init, end);
  print("calculating path");
  List<Vector2> path = getPath(traversed_map, init, end);
  for(Vector2 pos in path)
  {
    print("<- ${pos.x}, ${pos.y}");
  }
}*/