library base_geometry;

import 'package:vector_math/vector_math.dart';

class Vertex
{
  Vector3 position_;
  Vector3 orientation_;
  Vector2 text_coord_;
  Vector3 color_;

  Vertex.zero()
  {
    position_ = new Vector3.zero();
    orientation_ = new Vector3.zero();
    text_coord_ = new Vector2.zero();
    color_ = new Vector3.zero();
  }
}

class BaseGeometry
{

  List<double> vertices_;
  List<double> colors_;
  List<double> orientation_;
  List<int> indices_;

  BaseGeometry(this.vertices_, this.orientation_, this.indices_);
}

class TexturedGeometry extends BaseGeometry
{
  List<double> text_coords_;
  String image_;

  TexturedGeometry(List<double> vertices, List<double> orientation, List<int> indices, this.text_coords_, this.image_)
    : super(vertices, orientation, indices)
  {
  }

  int AddVertex(Vertex vert)
  {
    vertices_.add(vert.position_.x);
    vertices_.add(vert.position_.y);
    vertices_.add(vert.position_.z);
    orientation_.add(vert.orientation_.x);
    orientation_.add(vert.orientation_.y);
    orientation_.add(vert.orientation_.z);
    text_coords_.add(vert.text_coord_.x);
    text_coords_.add(vert.text_coord_.y);
    if (colors_ != null)
    {
      colors_.add(vert.color_.x);
      colors_.add(vert.color_.y);
      colors_.add(vert.color_.z);
    }

    return (vertices_.length / 3).round() - 1;
  }
}