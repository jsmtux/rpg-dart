library drawable_factory;

import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'drawable.dart';
import 'renderer.dart';
import 'base_geometry.dart';
import 'texture.dart';
import 'asset_manager.dart';
import 'animation.dart';

class DrawableFactory
{
  Renderer renderer_;
  AssetManager<Texture> texture_manager_;

  void initGeometry(BaseGeometry geometry, BaseDrawable drawable)
  {
    drawable.pos_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, drawable.pos_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.vertices_), webgl.RenderingContext.STATIC_DRAW);

    drawable.ind_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, drawable.ind_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(geometry.indices_),
        webgl.RenderingContext.STATIC_DRAW);

    if (geometry.orientation_ != null)
    {
      drawable.nor_buffer_ = renderer_.gl_.createBuffer();
      renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, drawable.nor_buffer_);
      renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
          new Float32List.fromList(geometry.orientation_), webgl.RenderingContext.STATIC_DRAW);
    }

    drawable.vertices_ = geometry.indices_.length;
  }

  void initTexture(TexturedGeometry geometry, BaseDrawable drawable)
  {
    drawable.tex_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, drawable.tex_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.text_coords_), webgl.RenderingContext.STATIC_DRAW);

    drawable.tex_.add(texture_manager_.getAsset(geometry.image_));
  }

  BaseDrawable createBaseDrawable(BaseGeometry geometry)
  {
    BaseDrawable ret = new BaseDrawable();
    initGeometry(geometry, ret);
    ret.shader_ = renderer_.texture_shader_;

    return ret;
  }

  BaseDrawable createTexturedDrawable(TexturedGeometry geometry)
  {
    BaseDrawable ret = new BaseDrawable();
    initGeometry(geometry, ret);
    initTexture(geometry, ret);
    if (geometry.orientation_ == null)
    {
      ret.shader_ = renderer_.texture_shader_;
    }
    else
    {
      ret.shader_ = renderer_.light_shader_;
    }

    return ret;
  }

  BaseDrawable createTerrainDrawable(TexturedGeometry geometry)
  {
    BaseDrawable ret = new BaseDrawable();
    initGeometry(geometry, ret);
    initTexture(geometry, ret);
    ret.shader_ = renderer_.light_shader_;

    return ret;
  }

  AnimatedDrawable createAnimatedDrawable(TexturedGeometry geometry, AnimationData animation)
  {
    AnimatedDrawable ret = new AnimatedDrawable();
    initGeometry(geometry, ret);
    initTexture(geometry, ret);

    ret.sequences_ = animation.sequences_;
    ret.num_images_side_ = animation.num_images_side_;
    ret.shader_ = renderer_.atlas_shader_;

    return ret;
  }

  DrawableFactory(this.renderer_)
  {
    texture_manager_ = new AssetManager((name) => new Texture(name, renderer_.gl_));
  }
}