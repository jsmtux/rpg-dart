library model_importer;

import "dart:convert";

import "async_importer.dart";
import "base_geometry.dart";

class ModelImporter extends AsyncImporter<List<BaseGeometry>>
{
  ModelImporter();

  List<BaseGeometry> processFile(String path)
  {
    List<BaseGeometry> ret = new List<BaseGeometry>();

    Map jsonData = JSON.decode(path);
    List materials = jsonData["materials"];

    List meshes = jsonData["meshes"];

    for (var mesh in meshes)
    {
      String texture = materials[mesh['material_index']];
      List<double> positions = mesh['vertices'][0];
      List<double> textures = mesh['vertices'][1];
      List<int> indices = mesh['indices'];
      BaseGeometry geom = new TexturedGeometry(positions, null, indices, textures, texture);
      ret.add(geom);
    }

    return ret;
  }
}