library camera;

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

class Camera
{
  Matrix4 cam_mat;

  Camera(this.cam_mat)
  {
    cam_mat.rotate(new Vector3(-1.0,0.0,0.0), radians(40.0));
    cam_mat.rotate(new Vector3(0.0,0.0,1.0), radians(45.0));
    cam_mat.translate(-15.0, -42.0, -5.0);
  }

  void SetPos(Vector2 vec, double rot)
  {
    cam_mat.setIdentity();
    cam_mat.rotate(new Vector3(-1.0,0.0,0.0), radians(50.0));
    cam_mat.rotate(new Vector3(0.0, 0.0, 1.0), rot);
    double xoffset = 3.5 * math.sin(rot);
    double yoffset = 3.5 * math.cos(rot);
    cam_mat.translate(vec.x + xoffset, yoffset + vec.y, -4.0);
  }
}