library Drawable;

import 'dart:web_gl' as webgl;
import 'dart:async';

import 'package:vector_math/vector_math.dart';

import 'animation.dart';
import 'texture.dart';
import 'shader.dart';

abstract class Drawable
{
  void Draw(webgl.RenderingContext gl_, Matrix4 world_view, Matrix4 perspective, int dimensions);
  bool isTransparent();
  void setTransparent(bool val);
  void setPosition(Vector3 pos);
  void move(Vector3 amount);
  void setScale(double scale);
  void setRotation(Quaternion rot);
  void Rotate(Quaternion rot);
}

class BaseDrawable implements Drawable
{
  webgl.Buffer pos_buffer_;
  webgl.Buffer ind_buffer_;
  webgl.Buffer color_buffer_;
  webgl.Buffer tex_buffer_;

  Vector3 position_ = new Vector3(0.0,0.0,0.0);
  Quaternion rotation_ = new Quaternion(0.0,0.0,0.0,1.0);
  double size_ = 1.0;

  Shader shader_;

  List<Texture> tex_ = new List<Texture>();
  int tex_cur_ind_ = 0;
  bool transparent_ = false;

  int vertices_;

  void Draw(webgl.RenderingContext gl_, Matrix4 world_view, Matrix4 perspective, int dimensions)
  {
    shader_.makeCurrent();
    Matrix4 m_modelview_ = new Matrix4.identity();
    m_modelview_.translate(position_);
    m_modelview_.setRotation(rotation_.asRotationMatrix());
    m_modelview_.scale(size_, size_, size_);

    gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, pos_buffer_);
    gl_.vertexAttribPointer(shader_.a_vertex_pos_, dimensions, webgl.RenderingContext.FLOAT, false, 0, 0);
    if(color_buffer_ != null)
    {
      gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, color_buffer_);
      gl_.vertexAttribPointer(shader_.a_vertex_color_, 4, webgl.RenderingContext.FLOAT, false, 0, 0);
    }
    if(tex_buffer_ != null)
    {
      tex_[tex_cur_ind_].makeCurrent();
      gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, tex_buffer_);
      gl_.vertexAttribPointer(shader_.a_vertex_coord_, 2, webgl.RenderingContext.FLOAT, false, 0, 0);
    }

    gl_.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, ind_buffer_);

    shader_.setMatrixUniforms(perspective, m_modelview_, world_view);
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
    size_ = scale;
  }

  void Rotate(Quaternion rot)
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

  void move(Vector3 amount)
  {
    position_ += amount;
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

  void Draw(webgl.RenderingContext gl_, Matrix4 world_view, Matrix4 perspective, int dimensions)
  {
    if (current_sequence_ != null)
    {
      ActivateImage(current_sequence_.images[current_in_sequence_]);
    }
    else
    {
      ActivateImage(idle_image);
    }
    super.Draw(gl_, world_view, perspective, dimensions);
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

    shader_.setOffset(offset);
    shader_.setSize(size);
  }
}
