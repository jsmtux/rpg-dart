library drawable_factory;

import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'drawable.dart';
import 'renderer.dart';
import 'base_geometry.dart';
import 'texture.dart';
import 'asset_manager.dart';

class DrawableFactory
{
  Renderer renderer_;
  AssetManager<Texture> texture_manager_;

  BaseDrawable createBaseDrawable(BaseGeometry geometry)
  {
    BaseDrawable ret = new BaseDrawable();
    ret.pos_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, ret.pos_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.vertices_), webgl.RenderingContext.STATIC_DRAW);

    ret.ind_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, ret.ind_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(geometry.indices_),
        webgl.RenderingContext.STATIC_DRAW);

    ret.vertices_ = geometry.indices_.length;

    return ret;
  }

  BaseDrawable createTexturedDrawable(TexturedGeometry geometry)
  {
    BaseDrawable ret = createBaseDrawable(geometry);

    ret.tex_buffer_ = renderer_.gl_.createBuffer();
    renderer_.gl_.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, ret.tex_buffer_);
    renderer_.gl_.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER,
        new Float32List.fromList(geometry.text_coords_), webgl.RenderingContext.STATIC_DRAW);

    ret.tex_ = texture_manager_.getAsset(geometry.image_);

    ret.shader_ = renderer_.texture_shader_;

    return ret;
  }

  DrawableFactory(this.renderer_)
  {
    texture_manager_ = new AssetManager((name) => new Texture(name, renderer_.gl_));
  }
}