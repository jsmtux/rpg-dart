library model_importer;

import "dart:convert";
import "dart:html";

import "base_geometry.dart";

class ModelImporter
{
  Function callback_;

  ModelImporter(){}
  ModelImporter.Async(this.callback_){}

  void RequestFile(String path)
  {
    HttpRequest.getString(path).then(getModel);
  }

  List<BaseGeometry> getModel(String data)
  {
    List<BaseGeometry> ret = new List<BaseGeometry>();

    Map jsonData = JSON.decode(data);
    List materials = jsonData["materials"];

    List meshes = jsonData["meshes"];

    for (var mesh in meshes)
    {
      String texture = materials[mesh['material_index']];
      List<double> positions = mesh['vertices'][0];
      List<double> textures = mesh['vertices'][1];
      List<int> indices = mesh['indices'];
      BaseGeometry geom = new TexturedGeometry(positions, indices, textures, texture);
      ret.add(geom);
    }

    if(callback_ != null)
    {
      callback_(ret);
    }
    return ret;
  }
}
