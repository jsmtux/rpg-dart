library ShaderProperties;

import 'dart:web_gl' as webgl;

import 'package:vector_math/vector_math.dart';

import 'shader_elements.dart';
import 'scene_lights.dart';

abstract class ShaderProperty
{
  void init(webgl.RenderingContext gl, webgl.Program shader_program);
  void update(webgl.RenderingContext gl);
  String getName();
}

class BasicShaderProperties extends ShaderProperty
{
  int a_vertex_pos_;
  int a_vertex_color_;
  int a_vertex_coord_;
  int a_vertex_normal_;

  Matrix4Uniform perspective_;
  Matrix4Uniform modelview_;
  Matrix4Uniform worldview_;

  webgl.RenderingContext gl_;

  void init(webgl.RenderingContext gl, webgl.Program shader_program)
  {
    gl_ = gl;
    a_vertex_pos_ = gl.getAttribLocation(shader_program, "aVertexPosition");
    gl.enableVertexAttribArray(a_vertex_pos_);

    a_vertex_color_ = gl.getAttribLocation(shader_program, "aVertexColor");
    if (a_vertex_color_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_color_);
    }

    a_vertex_normal_ = gl.getAttribLocation(shader_program, "aVertexNormal");
    if (a_vertex_normal_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_normal_);
    }

    a_vertex_coord_ = gl.getAttribLocation(shader_program, "aTextureCoord");
    if (a_vertex_coord_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_coord_);
    }

    perspective_ = new Matrix4Uniform(gl, shader_program, "uPMatrix");
    modelview_ = new Matrix4Uniform(gl, shader_program, "uMVMatrix");
    worldview_ = new Matrix4Uniform(gl, shader_program, "uWVMatrix");
  }

  void setMatrixUniforms(Matrix4 m_perspective, Matrix4 m_modelview, Matrix4 m_worldview)
  {
    perspective_.setData(m_perspective);
    modelview_.setData(m_modelview);
    worldview_.setData(m_worldview);
  }

  void update(webgl.RenderingContext gl)
  {
    perspective_.update();
    modelview_.update();
    worldview_.update();
  }

  static String propName = "BasicShaderProperties";
  String getName()
  {
    return propName;
  }
}

class AtlasTextureProperty extends ShaderProperty
{
  Vector2Uniform size_;
  Vector2Uniform offset_;

  void init(webgl.RenderingContext gl, webgl.Program shader_program)
  {
    size_ = new Vector2Uniform(gl, shader_program, "t_size");
    offset_ = new Vector2Uniform(gl, shader_program, "t_offset");
  }

  void update(webgl.RenderingContext gl)
  {
    size_.update();
    offset_.update();
  }

  void setOffset(Vector2 offset)
  {
    offset_.setData(offset);
  }

  void setSize(Vector2 size)
  {
    size_.setData(size);
  }

  static String propName = "AtlasTextureProperty";
  String getName()
  {
    return propName;
  }
}

class PointLightUniform
{
Vector3Uniform point_pos_;
Vector3Uniform point_color_;
Vector3Uniform point_attenuation_;
}

class LightingShaderProperty implements ShaderProperty, SceneLightsController
{
  Vector3Uniform directional_dir_;
  Vector3Uniform directional_color_;

  Vector3Uniform ambient_color_;

  Matrix3Uniform normal_;
  double angle_ = 45.0;
  static const int NUM_LIGHTS = 2;

  List<PointLightUniform> lights_ = new List<PointLightUniform>(NUM_LIGHTS);

  void init(webgl.RenderingContext gl, webgl.Program shader_program)
  {
    directional_dir_ = new Vector3Uniform(gl, shader_program, "uDirectionalDir");
    directional_color_ = new Vector3Uniform(gl, shader_program, "uDirectionalColor");
    ambient_color_ = new Vector3Uniform(gl, shader_program, "uAmbientColor");
    normal_ = new Matrix3Uniform(gl, shader_program, "uNMatrix");
    initializePointLights(gl, shader_program, NUM_LIGHTS);
  }

  void initializePointLights(webgl.RenderingContext gl, webgl.Program shader_program, int number)
  {
    for(int i = 0; i < number; i++)
    {
      lights_[i] = new PointLightUniform();
      lights_[i].point_pos_ = new Vector3Uniform(gl, shader_program, "lights[$i].uPos");
      lights_[i].point_color_ = new Vector3Uniform(gl, shader_program, "lights[$i].uColor");
      lights_[i].point_attenuation_ = new Vector3Uniform(gl, shader_program, "lights[$i].uAttenuation");
    }
  }

  void update(webgl.RenderingContext gl)
  {
    directional_dir_.update();

    directional_color_.update();
    ambient_color_.update();
    normal_.update();

    for(int i = 0; i < NUM_LIGHTS; i++)
    {
      lights_[i].point_pos_.update();
      lights_[i].point_color_.update();
      lights_[i].point_attenuation_.update();
    }
  }

  void setNormalMatrix(Matrix3 normal_mat)
  {
    normal_.setData(normal_mat);
  }

  void SetAmbientLight(BaseLight light)
  {
    ambient_color_.setData(light.color_);
  }

  void SetDirectionalLight(DirectionalLight light)
  {
    directional_color_.setData(light.color_);
    directional_dir_.setData(light.dir_);
  }

  void SetPointLight(PointLight light, int index)
  {
    lights_[index].point_color_.setData(light.color_);
    lights_[index].point_pos_.setData(light.pos_);
    lights_[index].point_attenuation_.setData(light.attenuation_);
  }

  static String propName = "LightingShaderProperty";
  String getName()
  {
    return propName;
  }
}
