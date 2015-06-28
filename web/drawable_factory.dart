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

  void initGeometry(BaseGeometry geometry, BaseDrawableBuffers buffers)
  {

    buffers.pos_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, buffers.pos_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.vertices_), webgl.RenderingContext.STATIC_DRAW);

    buffers.ind_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, buffers.ind_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(geometry.indices_),
        webgl.RenderingContext.STATIC_DRAW);

    if (geometry.orientation_ != null)
    {
      buffers.nor_buffer_ = renderer_.gl_.createBuffer();
      renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, buffers.nor_buffer_);
      renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
          new Float32List.fromList(geometry.orientation_), webgl.RenderingContext.STATIC_DRAW);
    }

    buffers.vertices_ = geometry.indices_.length;
  }

  void initTexture(TexturedGeometry geometry, BaseDrawableBuffers buffers)
  {
    buffers.tex_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, buffers.tex_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.text_coords_), webgl.RenderingContext.STATIC_DRAW);

    buffers.tex_ = texture_manager_.getAsset(geometry.image_);
  }

  BaseDrawable createBaseDrawable(BaseGeometry geometry)
  {
    BaseDrawableBuffers buffers = new BaseDrawableBuffers();
    initGeometry(geometry, buffers);
    BaseDrawable ret = new BaseDrawable(buffers);
    ret.shader_ = renderer_.texture_shader_;

    return ret;
  }

  BaseDrawable createTexturedDrawable(TexturedGeometry geometry)
  {
    BaseDrawableBuffers buffers = new BaseDrawableBuffers();
    if(geometry == null)
    {
      print('Uninitialised geometry in TexturedDrawable');
    }
    initGeometry(geometry, buffers);
    initTexture(geometry, buffers);
    BaseDrawable ret = new BaseDrawable(buffers);
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

  AnimatedBaseDrawable createAnimatedDrawable(List<BaseGeometry> geometry)
  {
    List<BaseDrawableBuffers> buffers = new List<BaseDrawableBuffers>();
    if(geometry == null)
    {
      print('Uninitialised geometry in TexturedDrawable');
    }
    for (TexturedGeometry g in geometry)
    {
      BaseDrawableBuffers buff = new BaseDrawableBuffers();
      initGeometry(g, buff);
      initTexture(g, buff);
      buffers.add(buff);
    }
    BaseDrawable ret = new AnimatedGeometry(buffers);
    if (geometry.first.orientation_ == null)
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
    BaseDrawableBuffers buffers = new BaseDrawableBuffers();
    initGeometry(geometry, buffers);
    initTexture(geometry, buffers);
    BaseDrawable ret = new BaseDrawable(buffers);
    ret.shader_ = renderer_.light_shader_;

    return ret;
  }

  AnimatedSprite createSpriteDrawable(TexturedGeometry geometry, AnimationData animation)
  {
    BaseDrawableBuffers buffers = new BaseDrawableBuffers();
    initGeometry(geometry, buffers);
    initTexture(geometry, buffers);
    AnimatedSprite ret = new AnimatedSprite(buffers);

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