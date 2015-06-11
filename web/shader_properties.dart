library ShaderProperties;

import 'dart:web_gl' as webgl;
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

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
  webgl.UniformLocation u_m_perspective_;
  webgl.UniformLocation u_m_modelview_;
  webgl.UniformLocation u_m_worldview_;

  Float32List ml_perspective_ = new Float32List(16);
  Float32List ml_modelview_ = new Float32List(16);
  Float32List ml_worldview_ = new Float32List(16);

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

    u_m_perspective_ = gl.getUniformLocation(shader_program, "uPMatrix");
    u_m_modelview_ = gl.getUniformLocation(shader_program, "uMVMatrix");
    u_m_worldview_ = gl.getUniformLocation(shader_program, "uWVMatrix");
  }

  void setMatrixUniforms(Matrix4 m_perspective, Matrix4 m_modelview, Matrix4 m_worldview)
  {
    m_perspective.copyIntoArray(ml_perspective_);
    m_modelview.copyIntoArray(ml_modelview_);
    m_worldview.copyIntoArray(ml_worldview_);
  }

  void update(webgl.RenderingContext gl)
  {
    if (ml_perspective_ != null)
    {
      gl_.uniformMatrix4fv(u_m_perspective_, false, ml_perspective_);
      gl_.uniformMatrix4fv(u_m_modelview_, false, ml_modelview_);
      gl_.uniformMatrix4fv(u_m_worldview_, false, ml_worldview_);
    }
  }

  static String propName = "BasicShaderProperties";
  String getName()
  {
    return propName;
  }
}

class AtlasTextureProperty extends ShaderProperty
{
  webgl.UniformLocation size_p_;
  webgl.UniformLocation offset_p_;

  Vector2 size_;
  Vector2 offset_;

  void init(webgl.RenderingContext gl, webgl.Program shader_program)
  {
    size_p_ = gl.getUniformLocation(shader_program, "t_size");
    offset_p_ = gl.getUniformLocation(shader_program, "t_offset");
  }

  void update(webgl.RenderingContext gl)
  {
    gl.uniform2f(size_p_, size_.x, size_.y);
    gl.uniform2f(offset_p_, offset_.x, offset_.y);
  }

  void setOffset(Vector2 offset)
  {
    offset_ = offset;
  }

  void setSize(Vector2 size)
  {
    size_ = size;
  }

  static String propName = "AtlasTextureProperty";
  String getName()
  {
    return propName;
  }
}

class LightingShaderProperty implements ShaderProperty
{
  webgl.UniformLocation u_v3_directional_dir_;
  webgl.UniformLocation u_v3_directional_color_;
  webgl.UniformLocation u_v3_ambient_color_;
  webgl.UniformLocation u_v3_point_pos_;
  webgl.UniformLocation u_m_normal_;


  Vector3 ambient_color_ = new Vector3(.2, .2, .2);
  Vector3 directional_color_ = new Vector3(0.3, 0.0, 0.3);
  Vector3 directional_dir_ = new Vector3(0.0, -1.0, 0.0);
  Vector3 point_pos_ = new Vector3(0.0, 0.0, 0.0);
  Matrix3 m_normal_ = new Matrix3.identity();
  double angle_ = 45.0;

  void init(webgl.RenderingContext gl, webgl.Program shader_program)
  {
    Quaternion directional_rotation = new Quaternion.axisAngle(new Vector3(1.0, 0.0, 0.0), angle_ * Math.PI / 180);
    directional_rotation.rotate(directional_dir_);
    directional_rotation = new Quaternion.axisAngle(new Vector3(0.0, 1.0, 0.0), 45.0 * Math.PI / 180);
    directional_rotation.rotate(directional_dir_);
    u_v3_directional_color_ = gl.getUniformLocation(shader_program, "uDirectionalColor");
    u_v3_directional_dir_ = gl.getUniformLocation(shader_program, "uLightingDirection");
    u_v3_ambient_color_ = gl.getUniformLocation(shader_program, "uAmbientLight");
    u_v3_point_pos_ = gl.getUniformLocation(shader_program, "uPointLightPos");
    u_m_normal_ = gl.getUniformLocation(shader_program, "uNMatrix");
  }

  void update(webgl.RenderingContext gl)
  {
    directional_dir_ = new Vector3(0.0, 1.0, 0.0);
    Quaternion directional_rotation = new Quaternion.axisAngle(new Vector3(-1.0, 0.0, 0.0),45.0 * Math.PI / 180);
    directional_rotation.rotate(directional_dir_);
    directional_rotation = new Quaternion.axisAngle(new Vector3(0.0, 0.0, 1.0), angle_ * Math.PI / 180);
    directional_rotation.rotate(directional_dir_);
    angle_ = (angle_ + 0.01) % 360;
    gl.uniform3f(u_v3_ambient_color_, ambient_color_.x, ambient_color_.y, ambient_color_.z);
    gl.uniform3f(u_v3_directional_color_, directional_color_.x, directional_color_.y, directional_color_.z);
    gl.uniform3f(u_v3_directional_dir_, directional_dir_.x, directional_dir_.y, directional_dir_.z);
    gl.uniform3f(u_v3_point_pos_, point_pos_.x, point_pos_.y, point_pos_.z);
    Float32List tmpList = new Float32List(9);
    m_normal_.copyIntoArray(tmpList);
    gl.uniformMatrix3fv(u_m_normal_, false, tmpList);
  }

  void setNormalMatrix(Matrix3 normal_mat)
  {
    m_normal_ = normal_mat;
  }

  void setPointLightPos(Vector3 pos)
  {
    point_pos_ = pos;
  }

  static String propName = "LightingShaderProperty";
  String getName()
  {
    return propName;
  }
}
