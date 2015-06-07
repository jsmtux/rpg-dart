library Drawable;

import 'dart:web_gl' as webgl;
import 'dart:async';

import 'package:vector_math/vector_math.dart';

import 'animation.dart';
import 'texture.dart';
import 'shader.dart';
import 'shader_properties.dart';

abstract class Drawable
{
  void draw(webgl.RenderingContext gl_, Matrix4 world_view, Matrix4 perspective, int dimensions);
  bool isTransparent();
  void setTransparent(bool val);
  void setPosition(Vector3 pos);
  Vector3 getPosition();
  void move(Vector3 amount);
  void setScale(double scale);
  void setRotation(Quaternion rot);
  void rotate(Quaternion rot);
  Vector3 getSize();
  void setSize(Vector3 size);
}

class BaseDrawable implements Drawable
{
  webgl.Buffer pos_buffer_;
  webgl.Buffer ind_buffer_;
  webgl.Buffer nor_buffer_;
  webgl.Buffer color_buffer_;
  webgl.Buffer tex_buffer_;

  Vector3 position_ = new Vector3(0.0,0.0,0.0);
  Quaternion rotation_ = new Quaternion(0.0,0.0,0.0,1.0);
  double scale_ = 1.0;
  Vector3 size_ = new Vector3(1.0, 1.0, 1.0);

  Shader shader_;

  List<Texture> tex_ = new List<Texture>();
  int tex_cur_ind_ = 0;
  bool transparent_ = false;

  int vertices_;

  void draw(webgl.RenderingContext gl_, Matrix4 world_view, Matrix4 perspective, int dimensions)
  {
    Matrix4 m_modelview_ = new Matrix4.identity();
    m_modelview_.translate(position_);
    m_modelview_.setRotation(rotation_.asRotationMatrix());
    m_modelview_.scale(scale_, scale_, scale_);

    BasicShaderProperties basic_property = shader_.getShaderProperty(BasicShaderProperties.propName);
    gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, pos_buffer_);
    gl_.vertexAttribPointer(basic_property.a_vertex_pos_, dimensions, webgl.RenderingContext.FLOAT, false, 0, 0);
    if(color_buffer_ != null)
    {
      gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, color_buffer_);
      gl_.vertexAttribPointer(basic_property.a_vertex_color_, 4, webgl.RenderingContext.FLOAT, false, 0, 0);
    }
    if(tex_buffer_ != null)
    {
      tex_[tex_cur_ind_].makeCurrent();
      gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, tex_buffer_);
      gl_.vertexAttribPointer(basic_property.a_vertex_coord_, 2, webgl.RenderingContext.FLOAT, false, 0, 0);
    }
    if(nor_buffer_ != null)
    {
      gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, nor_buffer_);
      gl_.vertexAttribPointer(basic_property.a_vertex_normal_, dimensions, webgl.RenderingContext.FLOAT, false, 0, 0);
    }

    gl_.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, ind_buffer_);

    basic_property.setMatrixUniforms(perspective, m_modelview_, world_view);

    DirectionalLightShaderProperty directional_property = shader_.getShaderProperty(DirectionalLightShaderProperty.propName);
    if (directional_property != null)
    {
      LightShader t_shader = shader_;
      Matrix3 m_normal = new Matrix3.identity();

      m_normal.setRow(0, m_modelview_.row0.xyz);
      m_normal.setRow(1, m_modelview_.row1.xyz);
      m_normal.setRow(2, m_modelview_.row2.xyz);
      m_normal.invert();
      m_normal.transpose();

      directional_property.setNormalMatrix(m_normal);
    }
    shader_.makeCurrent();
    gl_.drawElements(webgl.RenderingContext.TRIANGLES, vertices_, webgl.RenderingContext.UNSIGNED_SHORT, 0);
  }

  bool isTransparent()
  {
    return transparent_;
  }

  void setTransparent(bool val)
  {
    transparent_ = val;
  }

  void setScale(double scale)
  {
    scale_ = scale;
  }

  void rotate(Quaternion rot)
  {
    rotation_ *= rot;
  }

  void setRotation(Quaternion rot)
  {
    rotation_ = rot;
  }

  void setPosition(Vector3 pos)
  {
    position_ = pos;
  }

  Vector3 getPosition()
  {
    return position_;
  }

  void move(Vector3 amount)
  {
    position_ += amount;
  }

  Vector3 getSize()
  {
    return size_;
  }

  void setSize(Vector3 size)
  {
    size_ = size;
  }
}

class AnimatedDrawable extends BaseDrawable
{
  int num_images_side_;
  Map<String, AnimationSequence> sequences_;
  AtlasShader shader_;
  AnimationSequence current_sequence_;
  String current_sequence_name_;
  int current_in_sequence_;
  Future update_timer;
  int idle_image = 0;

  void draw(webgl.RenderingContext gl_, Matrix4 world_view, Matrix4 perspective, int dimensions)
  {
    if (current_sequence_ != null)
    {
      ActivateImage(current_sequence_.images[current_in_sequence_]);
    }
    else
    {
      ActivateImage(idle_image);
    }
    super.draw(gl_, world_view, perspective, dimensions);
  }

  void SetSequence(String seq_name, [int initial])
  {
    if (current_sequence_name_ != seq_name)
    {
      current_sequence_name_ = seq_name;
      current_sequence_ = sequences_[seq_name];
      current_in_sequence_ = initial;
      UpdateSequenceCounter();
    }
  }

  void StopAnimation()
  {
    if (current_sequence_ != null)
    {
      idle_image = current_sequence_.images.first;
      current_sequence_ = null;
      current_sequence_name_ = null;
    }
  }

  void UpdateSequenceCounter()
  {
    if (current_sequence_ != null)
    {
      if (update_timer == null)
      {
        int millis = (current_sequence_.time * 1000).floor();
        update_timer = new Future.delayed(new Duration(milliseconds : millis), finishUpdate);
      }
      if (current_in_sequence_ == null)
      {
        current_in_sequence_ = 0;
      }
      else
      {
        current_in_sequence_ = (current_in_sequence_ + 1);
        if (current_in_sequence_ >= current_sequence_.images.length)
        {
          StopAnimation();
        }
      }
    }
    else
    {
      update_timer = null;
    }
  }

  void finishUpdate()
  {
    update_timer = null;
    UpdateSequenceCounter();
  }

  void ActivateImage(int i)
  {
    int y = (i / num_images_side_).floor();
    int x = i - y * num_images_side_;

    Vector2 offset = new Vector2(x/num_images_side_, y/num_images_side_);
    Vector2 size = new Vector2(1/num_images_side_, 1/num_images_side_);

    AtlasTextureProperty atlas_prop = shader_.getShaderProperty(AtlasTextureProperty.propName);
    if(atlas_prop != null)
    {
      atlas_prop.setOffset(offset);
      atlas_prop.setSize(size);
    }
  }
}
