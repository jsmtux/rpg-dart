library json_importer;

import "dart:convert";
import "dart:html";

import 'package:vector_math/vector_math.dart';

import "square_terrain.dart";

class Tileset
{
  int first_gid;
  int root_size;
  String path;
}

class TerrainImporter
{
  Function callback_;

  TerrainImporter();
  TerrainImporter.Async(this.callback_);

  void RequestFile(String path)
  {
    HttpRequest.getString(path).then(getTerrain);
  }

  List<SquareTerrain> getTerrain(String data)
  {
    List<SquareTerrain> ret = new List<SquareTerrain>();

    Map jsonData = JSON.decode(data);

    Vector2 size = new Vector2.zero();
    size.y = jsonData["height"] * 1.0;
    size.x = jsonData["width"] * 1.0;

    List tilesets = jsonData["tilesets"];

    List<Tileset> parsed_tilesets = new List<Tileset>();

    for (Map tileset in tilesets)
    {
      Tileset current = new Tileset();
      current.first_gid = tileset["firstgid"];
      current.path = tileset["image"];
      current.root_size = (tileset["imageheight"] / tileset["tileheight"]).floor();
      current.root_size = current.root_size * current.root_size;
      parsed_tilesets.add(current);
    }

    List layers = jsonData["layers"];

    for (Map layer in layers)
    {
      List<int> data = layer["data"];
      int first_nonzero = 0;
      for(int num in data)
      {
        if (num != 0)
        {
          first_nonzero = num;
          break;
        }
      }

      if (first_nonzero == 0)
      {
        print("Empty layer");
      }
      else if (parsed_tilesets.isEmpty)
      {
        print("No available tilesets");
      }
      else
      {
        Tileset current_tileset = parsed_tilesets[0];

        for(Tileset tileset in parsed_tilesets)
        {
          if (tileset.first_gid < first_nonzero && tileset.first_gid < current_tileset.first_gid)
          {
            current_tileset = tileset;
          }
        }

        List<List<int>> heights = new List<List<int>>();
        List<List<int>> textures = new List<List<int>>();

        for (int i = 0; i < size.x; i++)
        {
          heights.add(new List<int>());
          textures.add(new List<int>());
          for (int j = 0; j < size.y; j++)
          {
            int height = 0;
            int texture = data[(i*size.x + j).floor()] - current_tileset.first_gid;
            /*if (data[(i*size.x + j).floor()] == 0)
            {
              height = -1;
            }*/

            heights[i].add(height);
            textures[i].add(texture);
          }
        }
        ret.add(new SquareTerrain(size, heights, current_tileset.path, textures, current_tileset.root_size));
      }
    }
    if(callback_ != null)
    {
      callback_(ret);
    }
    return ret;
  }
}
