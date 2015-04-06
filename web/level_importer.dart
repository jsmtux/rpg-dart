library Level_importer;

import "dart:convert";

import 'package:vector_math/vector_math.dart';

import "async_importer.dart";
import "square_terrain.dart";
import "level_data.dart";
import "path.dart";

class Tileset
{
  int first_gid;
  int root_size;
  String path;
  String name;
  Map properties;
}

class LevelImporter extends AsyncImporter<LevelData>
{
  LevelImporter();

  List<Tileset> readTilesets(List tilesets)
  {
    List<Tileset> parsed_tilesets = new List<Tileset>();

    for (Map tileset in tilesets)
    {
      Tileset current = new Tileset();
      current.first_gid = tileset["firstgid"];
      current.path = tileset["image"];
      current.name = tileset["name"];
      current.root_size = (tileset["imageheight"] / tileset["tileheight"]).floor();
      current.root_size = current.root_size * current.root_size;
      current.properties = tileset["tileproperties"];
      parsed_tilesets.add(current);
    }

    return parsed_tilesets;
  }

  Tileset getTileset(List tilesets, Map layer)
  {
    Tileset ret_tileset = tilesets[0];
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

    for(Tileset tileset in tilesets)
    {
      if (tileset.first_gid <= first_nonzero && tileset.first_gid > ret_tileset.first_gid)
      {
        ret_tileset = tileset;
      }
    }

    return ret_tileset;
  }

  List<Vector3> readModelData(List position, List layers, List<Tileset> parsed_tilesets, Vector2 size, List<String> model_paths)
  {
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
    for (Map layer in layers)
    {
      if (layer.containsKey("data"))
      {
        List<int> data = layer["data"];

        Tileset current_tileset = getTileset(parsed_tilesets, layer);

        if (current_tileset.name == "models_layer")
        {
          for (int i = 0; i < current_tileset.properties.length; i++)
          {
            model_paths.add(current_tileset.properties["${i}"]["name"]);
          }

          for (int i = 0; i < size.x; i++)
          {
            for (int j = 0; j < size.y; j++)
            {
              int texture = data[(i + j*size.x).floor()] - current_tileset.first_gid;
              if (texture >= 0)
              {
                Vector3 cur_model = new Vector3(i*1.0,size.y - j*1.0 ,texture*1.0);
                model_data.add(cur_model);
              }
            }
          }
        }
      }
    }

    return model_data;
  }

  List<List<int>> readHeightData(List layers, List<Tileset> parsed_tilesets, Vector2 size)
  {
    List<List<int>> heights = new List<List<int>>();

    for (Map layer in layers)
    {
      if (layer.containsKey("data"))
      {
        List<int> data = layer["data"];

        Tileset current_tileset = getTileset(parsed_tilesets, layer);

        if (current_tileset.name == "heights_layer")
        {
          for (int i = 0; i < size.x; i++)
          {
            heights.add(new List<int>());
            for (int j = 0; j < size.y; j++)
            {
              int height = data[(i + j*size.x).floor()] - current_tileset.first_gid;
              if (height < 0)
              {
                height = 0;
              }
              else if (height > 11)
              {
                if (height == 12)
                {
                  height = -2;
                }
                else if (height == 13)
                {
                  height = -3;
                }
                else if (height == 14)
                {
                  height = -4;
                }
                else if (height == 15)
                {
                  height = -5;
                }
                else
                {
                  height = 0;
                }
              }

              heights[i].add(height);
            }
          }
        }
      }
    }

    if (heights.length == 0)
    {
      for (int i = 0; i < size.x; i++)
      {
        heights.add(new List<int>());
        for (int j = 0; j < size.y; j++)
        {
          heights[i].add(0);
        }
      }
    }

    return heights;
  }

  LevelData processFile(String data)
  {
    List<SquareTerrain> ret_terrain = new List<SquareTerrain>();

    Map jsonData = JSON.decode(data);

    Map<String, Path> paths = new Map<String, Path>();
    Map<String, List<Vector2>> portals = new Map<String, List<Vector2>>();

    Vector2 size = new Vector2.zero();
    size.y = jsonData["height"] * 1.0;
    size.x = jsonData["width"] * 1.0;

    List<Tileset> parsed_tilesets = readTilesets(jsonData["tilesets"]);

    Vector3 offset = new Vector3.zero();
    if(jsonData.containsKey("properties"))
    {
      Map properties = jsonData["properties"];
      if (properties.containsKey("xoffset"))
      {
        offset.x = double.parse(properties["xoffset"]);
      }
      if (properties.containsKey("yoffset"))
      {
        offset.y = double.parse(properties["yoffset"]);
      }
      if (properties.containsKey("zoffset"))
      {
        offset.z = double.parse(properties["zoffset"]);
      }
    }

    List layers = jsonData["layers"];


    List<String> model_paths = new List<String>();
    List<Vector3> model_data = readModelData(jsonData["objects"], layers, parsed_tilesets, size, model_paths);

    List<List<int>> heights = readHeightData(layers, parsed_tilesets, size);

    for (Map layer in layers)
    {
      if (layer.containsKey("data"))
      {
        List<int> data = layer["data"];

        Tileset current_tileset = getTileset(parsed_tilesets, layer);

        if (current_tileset.name == "models_layer" || current_tileset.name == "heights_layer")
        {

        }
        else
        {
          List<List<int>> textures = new List<List<int>>();

          for (int i = 0; i < size.x; i++)
          {
            textures.add(new List<int>());
            for (int j = 0; j < size.y; j++)
            {
              int texture = data[(i + j*size.x).floor()] - current_tileset.first_gid;
              textures[i].add(texture);
            }
          }
          ret_terrain.add(new SquareTerrain(size, heights, current_tileset.path, textures, current_tileset.root_size));
        }
      }
      else
      {
        if (layer.containsKey("objects") && layer["name"] == "paths")
        {
          for (Map object in layer["objects"])
          {
            double path_scale = 0.0625;
            String name = object["name"];
            Vector2 pos = new Vector2.zero();
            pos.x = object["x"] * 1.0;
            pos.y = object["y"] * 1.0;
            List<Vector2> points = new List<Vector2>();
            for (Map point in object["polyline"])
            {
              Vector2 p_pos = new Vector2.zero();
              p_pos.x = ((point["x"] + pos.x) * path_scale).floorToDouble();
              p_pos.y = size.y - ((point["y"] + pos.y ) * path_scale).floorToDouble();
              points.add(p_pos);
            }
            Map properties = object["properties"];
            if (properties.length != 0)
            {
              String map_name = properties["map"];

              for(Vector2 point in points)
              {
                portals.putIfAbsent(map_name, () => new List<Vector2>());
                portals[map_name].add(point);
              }
            }
            else
            {
              paths[name] = new Path(name, points);
            }
          }
        }
      }
    }

    return new LevelData(ret_terrain, model_paths, model_data, heights, paths, portals, offset);
  }
}
