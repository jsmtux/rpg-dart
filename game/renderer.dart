library Renderer;

import 'dart:html';
import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

import 'camera.dart';
import 'drawable.dart';
import 'scene_lights.dart';
import 'shader.dart';
import 'shader_properties.dart';

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
  Shader light_shader_;
  Shader atlas_shader_;

  Uint8List last_captured_colour_map_;
  webgl.Texture fb_texture_;
  webgl.Renderbuffer render_buffer_;

  webgl.Framebuffer picking_buffer_;

  Vector2 mouse_pos_;

  Camera camera_;

  var on_resize_listener_;
  var on_orientation_listener_;

  Renderer(this.view_, this.canvas_, this.camera_)
  {
    window.onMouseDown.listen((event){mouse_pos_ = new Vector2(event.client.x *1.0, event.client.y * 1.0);});
    gl_ = canvas_.getContext('experimental-webgl');
    color_shader_ = createColorShader(gl_);
    texture_shader_ = createTextureShader(gl_);
    light_shader_ = createLightShader(gl_);
    atlas_shader_ = createAtlasShader(gl_);
    m_worldview_ = new Matrix4.identity();
  }

  void init()
  {
    resetListeners();
    setSize();
    on_resize_listener_ = window.onResize.listen((event) {
      setSize();
      updateFrameBufferSize();
    });
    on_orientation_listener_ = window.onDeviceOrientation.listen((event) {
      setSize();
      updateFrameBufferSize();
    });

    gl_.clearColor(1.0, 1.0, 1.0, 1.0);
    gl_.enable(webgl.RenderingContext.DEPTH_TEST);
    gl_.blendFunc(webgl.RenderingContext.SRC_ALPHA, webgl.RenderingContext.ONE_MINUS_SRC_ALPHA);
    gl_.enable(webgl.RenderingContext.BLEND);

    setupFrameBuffer();
  }

  void resetListeners()
  {
    if(on_resize_listener_ != null)
    {
      on_resize_listener_.cancel();
    }
    if(on_orientation_listener_ != null)
    {
      on_orientation_listener_.cancel();
    }
  }

  void stop()
  {
    view_.style.height = '0px';
    view_.style.width = '0px';
    resetListeners();
  }

  SceneLightsController getLightsController()
  {
    LightingShaderProperty lighting_property = light_shader_.getShaderProperty(LightingShaderProperty.propName);
    return lighting_property;
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

  void setupFrameBuffer()
  {
    picking_buffer_ = gl_.createFramebuffer();
    gl_.bindFramebuffer(webgl.FRAMEBUFFER, picking_buffer_);
    fb_texture_ = gl_.createTexture();
    gl_.bindTexture(webgl.TEXTURE_2D, fb_texture_);
    gl_.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_MAG_FILTER, webgl.NEAREST);
    gl_.texParameteri(webgl.TEXTURE_2D, webgl.TEXTURE_MIN_FILTER, webgl.NEAREST);
    render_buffer_ = gl_.createRenderbuffer();
    updateFrameBufferSize();
  }

  void updateFrameBufferSize()
  {
    last_captured_colour_map_ = new Uint8List(view_width_ * view_height_ * 4);
    gl_.bindTexture(webgl.TEXTURE_2D, fb_texture_);
    gl_.texImage2DTyped(webgl.TEXTURE_2D, 0, webgl.RGBA, canvas_.width, canvas_.height, 0, webgl.RGBA, webgl.UNSIGNED_BYTE, last_captured_colour_map_);
    gl_.bindRenderbuffer(webgl.RENDERBUFFER, render_buffer_);
    gl_.renderbufferStorage(webgl.RENDERBUFFER, webgl.DEPTH_COMPONENT16, canvas_.width, canvas_.height);
    gl_.framebufferTexture2D(webgl.FRAMEBUFFER, webgl.COLOR_ATTACHMENT0, webgl.TEXTURE_2D, fb_texture_, 0);
    gl_.framebufferRenderbuffer(webgl.FRAMEBUFFER, webgl.DEPTH_ATTACHMENT, webgl.RENDERBUFFER, render_buffer_);
    gl_.bindTexture(webgl.TEXTURE_2D, null);
    gl_.bindRenderbuffer(webgl.RENDERBUFFER, null);
    gl_.bindFramebuffer(webgl.FRAMEBUFFER, null);
  }

  void resize(Event e)
  {

  }

  bool inViewPort(Drawable drawable, Camera cam)
  {
    return drawable.getPosition().xy.distanceTo(-cam.GetPos().xy) < 25.0 + drawable.getSize().xy.length;
    //return true;
  }

  List<int> GetColourMapColour(Vector2 pos)
  {
    List<int> ret;
    if (pos.x >= view_width_ || pos.y >= view_height_ || pos.x < 0 || pos.y < 0)
    {
      print("invalid mouse coordinates");
    }
    else if (last_captured_colour_map_ == null)
    {
      print("Colour map not captured");
    }
    else
    {
      var first_address = (view_height_ - 1 - pos.y.floor()) * view_width_ * 4 + pos.x.floor() * 4;
      ret = new List<int>();
      ret.add(last_captured_colour_map_[first_address]);
      ret.add(last_captured_colour_map_[first_address + 1]);
      ret.add(last_captured_colour_map_[first_address + 2]);
    }
    return ret;
  }

  Vector2 renderPicking(List<List<Drawable>> drawables, Vector2 mouse_pos)
  {
    gl_.bindFramebuffer(webgl.FRAMEBUFFER, picking_buffer_);
    gl_.viewport(0, 0, view_width_, view_height_);

    gl_.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);

    m_worldview_ = camera_.GetMat();

    m_perspective_ = makePerspectiveMatrix(radians(45.0), view_width_/view_height_, 0.1, 100.0);
    for(List<Drawable> list in drawables)
    {
      for(Drawable d in list)
      {
        if (inViewPort(d, camera_))
        {
          if(!d.isTransparent() && d.pickable())
          {
            d.drawPick(gl_, m_worldview_, m_perspective_, dimensions_);
          }
        }
      }
    }
    gl_.readPixels(0, 0, view_width_, view_height_, webgl.RGBA, webgl.UNSIGNED_BYTE, last_captured_colour_map_);
    List<int> colour = this.GetColourMapColour(mouse_pos);
    gl_.bindFramebuffer(webgl.FRAMEBUFFER, null);
    return new Vector2(colour[0] / 255, colour[1] / 255);
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
            d.draw(gl_, m_worldview_, m_perspective_, dimensions_);
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
      d.draw(gl_, m_worldview_, m_perspective_, dimensions_);
    }
    gl_.depthMask(true);
  }
}