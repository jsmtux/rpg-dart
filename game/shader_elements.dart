library shader_elements;

import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

class Vector3Uniform
{
  webgl.UniformLocation u_location_;
  webgl.RenderingContext gl_;
  Vector3 data_;
  bool updated_ = false;

  Vector3Uniform(this.gl_, webgl.Program shader_program, String name, [this.data_])
  {
    u_location_ = gl_.getUniformLocation(shader_program, name);
    if (data_ == null)
    {
      data_ = new Vector3.zero();
    }
  }

  void update()
  {
    if (!updated_)
    {
      gl_.uniform3f(u_location_, data_.x, data_.y, data_.z);
      updated_ = true;
    }
  }

  void setData(Vector3 data)
  {
    updated_ = false;
    data_ = data;
  }
}

class Vector2Uniform
{
  webgl.UniformLocation u_location_;
  webgl.RenderingContext gl_;
  Vector2 data_;
  bool updated_ = false;

  Vector2Uniform(this.gl_, webgl.Program shader_program, String name, [this.data_])
  {
    u_location_ = gl_.getUniformLocation(shader_program, name);
    if (data_ == null)
    {
      data_ = new Vector2.zero();
    }
  }

  void update()
  {
    if(!updated_)
    {
      updated_ = true;
      gl_.uniform2f(u_location_, data_.x, data_.y);
    }
  }

  void setData(Vector2 data)
  {
    updated_ = false;
    data_ = data;
  }
}

class Matrix3Uniform
{
  webgl.UniformLocation u_location_;
  webgl.RenderingContext gl_;
  Float32List data_ = new Float32List(9);
  bool updated_ = false;

  Matrix3Uniform(this.gl_, webgl.Program shader_program, String name, [Matrix3 initial])
  {
    u_location_ = gl_.getUniformLocation(shader_program, name);
    if(initial == null)
    {
      setData(new Matrix3.identity());
    }
    else
    {
      setData(initial);
    }
  }

  void update()
  {
    if(!updated_)
    {
      updated_ = true;
      gl_.uniformMatrix3fv(u_location_, false, data_);
    }
  }

  void setData(Matrix3 data)
  {
    updated_ = false;
    data.copyIntoArray(data_);
  }
}

class Matrix4Uniform
{
  webgl.UniformLocation u_location_;
  webgl.RenderingContext gl_;
  Float32List data_ = new Float32List(16);
  bool updated_ = false;

  Matrix4Uniform(this.gl_, webgl.Program shader_program, String name, [Matrix4 initial])
  {
    u_location_ = gl_.getUniformLocation(shader_program, name);
    if(initial == null)
    {
      setData(new Matrix4.identity());
    }
    else
    {
      setData(initial);
    }
  }

  void update()
  {
    if(!updated_)
    {
      updated_ = true;
      gl_.uniformMatrix4fv(u_location_, false, data_);
    }
  }

  void setData(Matrix4 data)
  {
    updated_ = false;
    data.copyIntoArray(data_);
  }
}