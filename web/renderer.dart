library Renderer;

import 'dart:html';
import 'dart:web_gl' as webgl;
import 'shader.dart';

import 'package:vector_math/vector_math.dart';

import 'camera.dart';
import 'drawable.dart';

class Renderer
{
  CanvasElement canvas_;
  DivElement view_;
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
  Shader terrain_shader_;
  Shader atlas_shader_;

  Camera camera_;

  Renderer(DivElement div, this.canvas_, this.camera_)
  {
    view_ = div;
    setSize();
    window.onResize.listen((event) {
      setSize();
    });
    window.onDeviceOrientation.listen((event) {
      setSize();
    });
    gl_ = canvas_.getContext('experimental-webgl');
    color_shader_ = createColorShader(gl_);
    texture_shader_ = createTextureShader(gl_);
    terrain_shader_ = createTerrainShader(gl_);
    atlas_shader_ = createAtlasShader(gl_);
    m_worldview_ = new Matrix4.identity();

    gl_.clearColor(1.0, 1.0, 1.0, 1.0);
    gl_.enable(webgl.RenderingContext.DEPTH_TEST);
    gl_.blendFunc(webgl.RenderingContext.SRC_ALPHA, webgl.RenderingContext.ONE_MINUS_SRC_ALPHA);
    gl_.enable(webgl.RenderingContext.BLEND);
  }

  void setSize()
  {
    int new_height = window.innerHeight;
    int new_width = window.innerWidth;
    view_.style.height = new_height.toString() + 'px';
    view_.style.width = new_width.toString() + 'px';
    canvas_.height = new_height;
    canvas_.width = new_width;
    view_width_ = new_width;
    view_height_ = new_height;
    view_.style.marginTop = (-new_height / 2).toString() + 'px';
    view_.style.marginLeft = (-new_width / 2).toString() + 'px';
  }

  void resize(Event e)
  {

  }

  void renderElement(Drawable d)
  {
    d.draw(gl_, m_worldview_, m_perspective_, dimensions_);
  }

  bool inViewPort(Drawable drawable, Camera cam)
  {
    return drawable.getPosition().xy.distanceTo(-cam.GetPos().xy) < 25.0 + drawable.getSize().xy.length;
  }

  void render(List<List<Drawable>> drawables)
  {
    gl_.viewport(0, 0, view_width_, view_height_);
    gl_.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);

    m_worldview_ = camera_.GetMat();

    m_perspective_ = makePerspectiveMatrix(radians(45.0), view_width_/view_height_, 0.1, 100.0);

    List<Drawable> sorted_drawables = new List<Drawable>();
    for(List<Drawable> list in drawables)
    {
      for(Drawable d in list)
      {
        if (inViewPort(d, camera_))
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