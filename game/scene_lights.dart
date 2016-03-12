library scene_lights;

import 'package:vector_math/vector_math.dart';

class BaseLight
{
  Vector3 color_;
  BaseLight(this.color_);
}

class DirectionalLight extends BaseLight
{
  Vector3 dir_;
  DirectionalLight(this.dir_, Vector3 color) : super(color);
}

class PointLight extends BaseLight
{
  Vector3 pos_;
  Vector3 attenuation_;
  PointLight(this.pos_, this.attenuation_, Vector3 color) : super(color);
}

abstract class SceneLightsController
{
  void SetAmbientLight(BaseLight light);
  void SetDirectionalLight(DirectionalLight light);
  void SetPointLight(PointLight light, int index);
}