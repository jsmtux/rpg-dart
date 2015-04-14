library camera;

import 'package:vector_math/vector_math.dart';

class Camera
{
  Matrix4 cam_mat;

  Camera(this.cam_mat)
  {
    cam_mat.rotate(new Vector3(-1.0,0.0,0.0), radians(45.0));
    cam_mat.translate(-4.0, 3.0, -10.0);
  }

  void SetPos(Vector2 vec)
  {
    cam_mat.setIdentity();
    cam_mat.rotate(new Vector3(-1.0,0.0,0.0), radians(45.0));
    cam_mat.translate(vec.x, 12.0 + vec.y, -15.0);
  }
}