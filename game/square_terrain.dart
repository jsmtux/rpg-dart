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
  int num_images_;
  int map_scale_ = 5;

  SquareTerrain(this.size_, this.heights_, this.image_, this.textures_, this.num_images_);

  BaseGeometry calculateBaseGeometry(double height)
  {
    TexturedGeometry ret =
        new TexturedGeometry(new List<double>(), new List<double>(), new List<int>(), new List<double>(), this.image_);
    ret.colors_ = new List<double>();
    int bleeding_correction_factor = 512;
    double bleeding_correction = 1/bleeding_correction_factor;
    int num_images_root = math.sqrt(num_images_).floor();
    Vector2 tex_size = new Vector2(1/num_images_root - bleeding_correction, 1/num_images_root - bleeding_correction);

    for(int i = 0; i < size_.x; i++)
    {
      for (int j = 0; j < size_.y; j++)
      {
        int num_texture = textures_[i][j];
        if (heights_[i][j] == - 1 || num_texture <= 0)
        {
          continue;
        }
        int num_texture_y = (num_texture / num_images_root).floor();
        Vector2 tex_offset = new Vector2.zero();
        tex_offset.x = num_texture /num_images_root - num_texture_y + bleeding_correction / 2;
        tex_offset.y = num_texture_y /num_images_root + bleeding_correction / 2;

        Vertex va = new Vertex.zero();
        va.position_.x = i*1.0;
        va.color_.x = va.position_.x / size_.x;
        va.position_.y = size_.y - (j-1)*1.0;
        va.text_coord_.x = tex_offset.x;
        va.text_coord_.y = tex_offset.y;
        va.color_.x = va.position_.x / size_.x;
        va.color_.y = va.position_.y / size_.y;
        Vertex vb = new Vertex.zero();
        vb.position_.x = i*1.0;
        vb.position_.y = size_.y - j*1.0;
        vb.text_coord_.x = tex_offset.x;
        vb.text_coord_.y = tex_offset.y + tex_size.y;
        vb.color_.x = vb.position_.x / size_.x;
        vb.color_.y = vb.position_.y / size_.y;
        Vertex vc = new Vertex.zero();
        vc.position_.x = (i+1)*1.0;
        vc.position_.y = size_.y - (j-1)*1.0;
        vc.text_coord_.x = tex_offset.x + tex_size.x;
        vc.text_coord_.y = tex_offset.y;
        vc.color_.x = vc.position_.x / size_.x;
        vc.color_.y = vc.position_.y / size_.y;
        Vertex vd = new Vertex.zero();
        vd.position_.x = (i+1)*1.0;
        vd.position_.y = size_.y - j*1.0;
        vd.text_coord_.x = tex_offset.x + tex_size.x;
        vd.text_coord_.y = tex_offset.y + tex_size.y;
        vd.color_.x = vd.position_.x / size_.x;
        vd.color_.y = vd.position_.y / size_.y;

        if (heights_[i][j] >= 0)
        {
          va.position_.z = heights_[i][j] / map_scale_ + height;
          vb.position_.z = heights_[i][j] / map_scale_ + height;
          vc.position_.z = heights_[i][j] / map_scale_ + height;
          vd.position_.z = heights_[i][j] / map_scale_ + height;
        }
        else if (heights_[i][j] == -2)
        {
          va.position_.z = heights_[i-1][j] / map_scale_ + height;
          vb.position_.z = heights_[i-1][j] / map_scale_ + height;
          vc.position_.z = heights_[i+1][j] / map_scale_ + height;
          vd.position_.z = heights_[i+1][j] / map_scale_ + height;
        }
        else if (heights_[i][j] == -3)
        {
          va.position_.z = heights_[i][j-1] / map_scale_ + height;
          vb.position_.z = heights_[i][j+1] / map_scale_ + height;
          vc.position_.z = heights_[i][j-1] / map_scale_ + height;
          vd.position_.z = heights_[i][j+1] / map_scale_ + height;
        }
        else if (heights_[i][j] < -3)
        {
          va.position_.z = heights_[i-1][j-1] / map_scale_ + height;
          vb.position_.z = heights_[i-1][j+1] / map_scale_ + height;
          vc.position_.z = heights_[i+1][j-1] / map_scale_ + height;
          vd.position_.z = heights_[i+1][j+1] / map_scale_ + height;
        }

        Vector3 p1 = va.position_ - vb.position_;
        Vector3 p2 = va.position_ - vc.position_;

        Vector3 normal = p1.cross(p2);

        va.orientation_ = vb.orientation_ = vc.orientation_ = vd.orientation_ = normal;

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
