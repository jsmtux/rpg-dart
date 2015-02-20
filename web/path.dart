library path;

import 'package:vector_math/vector_math.dart';

class Path
{
  String name;
  Vector2 position;
  List<Vector2> points;

  Path(this.name, this.position, this.points);
}