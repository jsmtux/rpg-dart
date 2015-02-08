library Level_importer;

import "dart:convert";

import 'package:vector_math/vector_math.dart';

import "async_importer.dart";
import "square_terrain.dart";
import "level_data.dart";

class Tileset
{
  int first_gid;
  int root_size;
  String path;
}

class LevelImporter extends AsyncImporter<LevelData>
{
  LevelImporter();

  LevelData processFile(String data)
  {
    List<SquareTerrain> ret_terrain = new List<SquareTerrain>();

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
      String path = current.path;
      current.root_size = (tileset["imageheight"] / tileset["tileheight"]).floor();
      current.root_size = current.root_size * current.root_size;
      parsed_tilesets.add(current);
    }

    List<String> model_paths = jsonData["models"];

    /* Models defined in the right format */
    List position = jsonData["objects"];
    List<Vector3> model_data = new List<Vector3>();

    if (position != null)
    {
      for (Map model in position)
      {
        Vector3 cur_model = new Vector3.zero();
        cur_model.x = model["position"][0] * 1.0;
        cur_model.y = model["position"][1] * 1.0;
        cur_model.z = model["id"] * 1.0;
        model_data.add(cur_model);
      }
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
          if (tileset.first_gid <= first_nonzero && tileset.first_gid > current_tileset.first_gid)
          {
            current_tileset = tileset;
          }
        }
        String tileset_name = current_tileset.path;

        if (current_tileset.path == "models_layer")
        {
          for (int i = 0; i < size.x; i++)
          {
            for (int j = 0; j < size.y; j++)
            {
              int texture = data[(i*size.x + j).floor()] - current_tileset.first_gid;
              if (texture >= 0)
              {
                Vector3 cur_model = new Vector3(j*1.0,size.y - i*1.0,texture*1.0);
                model_data.add(cur_model);
              }
            }
          }
        }
        else
        {
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
          ret_terrain.add(new SquareTerrain(size, heights, current_tileset.path, textures, current_tileset.root_size));
        }
      }
    }

    return new LevelData(ret_terrain, model_paths, model_data);
  }
}
