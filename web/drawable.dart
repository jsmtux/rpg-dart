library Drawable;

import 'dart:web_gl' as webgl;

import 'package:vector_math/vector_math.dart';

import 'texture.dart';
import 'shader.dart';

abstract class Drawable
{
  void Draw(webgl.RenderingContext gl_, Matrix4 world_view, Matrix4 perspective, int dimensions);
  bool isTransparent();
  void setPosition(Vector3 pos);
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
}

class AnimationSequence
{
  List<int> images;
  double time;
}

class AnimatedDrawable
{
  int num_images_side_;
  Map<String, AnimationSequence> sequences_;

  void activateImage(int i)
  {
    int x = (i / num_images_side_).floor();
    int y = num_images_side_ - x;

    Vector2 offset = new Vector2(x/num_images_side_, y/num_images_side_);
    Vector2 size = new Vector2(1/num_images_side_, 1/num_images_side_);
  }
}
