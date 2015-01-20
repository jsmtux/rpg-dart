library square_terrain;

import 'dart:math' as math;

import 'base_geometry.dart';

import 'package:vector_math/vector_math.dart';

class SquareTerrain
{
  List<List<int>> heights_ = new List<List<int>>();
  List<List<int>> textures_ = new List<List<int>>();
  Vector2 size_;
  String image_;
  int num_images_root_;
  int map_scale_ = 5;

  SquareTerrain(this.size_, this.heights_, this.image_, this.textures_, int num_images)
  {
    num_images_root_ = math.sqrt(num_images).floor();
  }

  BaseGeometry calculateBaseGeometry()
  {
    TexturedGeometry ret = new TexturedGeometry(new List<double>(), new List<int>(), new List<double>(), this.image_);

    for(int i = 0; i < size_.x; i++)
    {
      for (int j = 0; j < size_.y; j++)
      {
        if (heights_[i][j] == -1)
        {
          continue;
        }
        int num_texture = textures_[i][j];
        int num_texture_x = (num_texture / num_images_root_).floor();
        Vector2 tex_offset = new Vector2.zero();
        tex_offset.x = num_texture_x / num_images_root_;
        tex_offset.y = (num_texture - num_texture_x) / num_images_root_;
        Vector2 tex_size = new Vector2(1/num_images_root_, 1/num_images_root_);

        Vertex va = new Vertex.zero();
        va.position_.x = i*1.0;
        va.position_.y = j*1.0;
        va.text_coord_.x = tex_offset.x;
        va.text_coord_.y = tex_offset.y;
        Vertex vb = new Vertex.zero();
        vb.position_.x = i*1.0;
        vb.position_.y = (j+1)*1.0;
        vb.text_coord_.x = tex_offset.x;
        vb.text_coord_.y = tex_offset.y + tex_size.y;
        Vertex vc = new Vertex.zero();
        vc.position_.x = (i+1)*1.0;
        vc.position_.y = j*1.0;
        vc.text_coord_.x = tex_offset.x + tex_size.x;
        vc.text_coord_.y = tex_offset.y;
        Vertex vd = new Vertex.zero();
        vd.position_.x = (i+1)*1.0;
        vd.position_.y = (j+1)*1.0;
        vd.text_coord_.x = tex_offset.x + tex_size.x;
        vd.text_coord_.y = tex_offset.y + tex_size.y;

        if (heights_[i][j] >= 0)
        {
          va.position_.z = heights_[i][j] / map_scale_;
          vb.position_.z = heights_[i][j] / map_scale_;
          vc.position_.z = heights_[i][j] / map_scale_;
          vd.position_.z = heights_[i][j] / map_scale_;
        }
        else if (heights_[i][j] == -2)
        {
          va.position_.z = heights_[i-1][j] / map_scale_;
          vb.position_.z = heights_[i-1][j] / map_scale_;
          vc.position_.z = heights_[i+1][j] / map_scale_;
          vd.position_.z = heights_[i+1][j] / map_scale_;
        }
        else
        {
          va.position_.z = heights_[i][j-1] / map_scale_;
          vb.position_.z = heights_[i][j+1] / map_scale_;
          vc.position_.z = heights_[i][j-1] / map_scale_;
          vd.position_.z = heights_[i][j+1] / map_scale_;
        }

        int ia = ret.AddVertex(va);
        int ib = ret.AddVertex(vb);
        int ic = ret.AddVertex(vc);
        int id = ret.AddVertex(vd);

        ret.indices_.add(ia);
        ret.indices_.add(id);
        ret.indices_.add(ib);
        ret.indices_.add(ia);
        ret.indices_.add(ic);
        ret.indices_.add(id);
      }
    }

    return ret;
  }
}
