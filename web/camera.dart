library camera;

import 'package:vector_math/vector_math.dart';

class Camera
{
  Matrix4 cam_mat_ = new Matrix4.zero();
  Vector3 pos_ = new Vector3(0.0, 0.0, 0.0);
  Vector3 offset_ = new Vector3(0.0, 10.0, -10.0);

  Camera()
  {
    cam_mat_.rotate(new Vector3(-1.0,0.0,0.0), radians(45.0));
  }

  void SetPos(Vector2 vec)
  {
    pos_.xy = vec;
    cam_mat_.setIdentity();
    cam_mat_.rotate(new Vector3(-1.0,0.0,0.0), radians(45.0));
    cam_mat_.translate(pos_.x + offset_.x, pos_.y + offset_.y, offset_.z);
  }

  Matrix4 GetMat()
  {
    return cam_mat_;
  }

  Vector3 GetPos()
  {
    return pos_;
  }
}