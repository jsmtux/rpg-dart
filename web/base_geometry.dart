library base_geometry;

import 'package:vector_math/vector_math.dart';

class Vertex
{
  Vector3 position_;
  Vector3 orientation_;
  Vector2 text_coord_;

  Vertex.zero()
  {
    position_ = new Vector3.zero();
    orientation_ = new Vector3.zero();
    text_coord_ = new Vector2.zero();
  }
}

class BaseGeometry
{

  List<double> vertices_;
  List<double> orientation_;
  List<int> indices_;

  BaseGeometry(this.vertices_, this.orientation_, this.indices_);
}

class ColoredGeometry extends BaseGeometry
{
  List<double> colors_;

  ColoredGeometry(List<double> vertices, List<double> orientation, List<int> indices, this.colors_)
      : super(vertices, orientation, indices)
  {}

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

    return (vertices_.length / 3).round() - 1;
  }
}