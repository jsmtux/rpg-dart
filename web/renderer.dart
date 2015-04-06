library Renderer;

import 'dart:html';
import 'dart:web_gl' as webgl;
import 'shader.dart';

import 'package:vector_math/vector_math.dart';

import 'drawable.dart';

class Renderer
{
  CanvasElement canvas_;
  webgl.RenderingContext gl_;
  webgl.Program shader_program_;

  int dimensions_ = 3;
  int view_width_;
  int view_height_;

  Matrix4 m_perspective_;
  Matrix4 m_modelview_;
  Matrix4 m_worldview_;

  Shader color_shader_;
  Shader texture_shader_;
  Shader atlas_shader_;

  Renderer(CanvasElement canvas)
  {
    canvas_ = canvas;
    canvas.height = window.innerHeight - 20;
    canvas.width = window.innerWidth - 20;
    view_width_ = canvas.width;
    view_height_ = canvas.height;
    window.onResize.listen((event) {
      canvas.height = window.innerHeight;
      canvas.width = window.innerWidth;
      view_width_ = canvas.width;
      view_height_ = canvas.height;
          });
    gl_ = canvas.getContext('experimental-webgl');
    color_shader_ = createColorShader(gl_);
    texture_shader_ = createTextureShader(gl_);
    atlas_shader_ = createAtlasShader(gl_);
    m_worldview_ = new Matrix4.identity();

    gl_.clearColor(1.0, 1.0, 1.0, 1.0);
    gl_.enable(webgl.RenderingContext.DEPTH_TEST);
    gl_.blendFunc(webgl.RenderingContext.SRC_ALPHA, webgl.RenderingContext.ONE_MINUS_SRC_ALPHA);
    gl_.enable(webgl.RenderingContext.BLEND);
  }

  void resize(Event e)
  {

  }

  void renderElement(Drawable d)
  {
    d.Draw(gl_, m_worldview_, m_perspective_, dimensions_);
  }

  void render(List<List<Drawable>> drawables)
  {
    gl_.viewport(0, 0, view_width_, view_height_);
    gl_.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);

    m_perspective_ = makePerspectiveMatrix(radians(45.0), view_width_/view_height_, 0.1, 100.0);

    List<Drawable> sorted_drawables = new List<Drawable>();
    for(List<Drawable> list in drawables)
    {
      for(Drawable d in list)
      {
        if(!d.isTransparent())
        {
          renderElement(d);
        }
        else
        {
          sorted_drawables.add(d);
        }
      }
    }

    sorted_drawables.sort((x,y) => y.position_.y.compareTo(x.position_.y));
    gl_.depthMask(false);
    for(Drawable d in sorted_drawables)
    {
      renderElement(d);
    }
    gl_.depthMask(true);
  }
}