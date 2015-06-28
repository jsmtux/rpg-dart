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

  Tileset getTileTileset(List tilesets, int num)
  {
    Tileset ret_tileset = tilesets[0];
    for(Tileset tileset in tilesets)
    {
      if (tileset.first_gid <= num && tileset.first_gid > ret_tileset.first_gid)
      {
        ret_tileset = tileset;
      }
    }
    return ret_tileset;
  }

  Tileset getTileset(List tilesets, Map layer)
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

    return getTileTileset(tilesets, first_nonzero);
  }

  List<ModelDescription> readModelDescriptions(List tilesets)
  {
    List<ModelDescription> ret = new List<ModelDescription>();
    for (Tileset current_tileset in tilesets)
    {
      if (current_tileset.properties != null)
      {
        for (int i = 0; i < current_tileset.properties.length; i++)
        {
          if (current_tileset.properties.containsKey("${i}") && current_tileset.properties["${i}"].containsKey("path"))
          {
            String name = current_tileset.properties["${i}"]["path"];
            if (name.endsWith(".model"))
            {
              ModelDescription toAdd = new ModelDescription();
              toAdd.path_ = name;
              if(current_tileset.properties["${i}"].containsKey("height"))
              {
                toAdd.height_ = double.parse(current_tileset.properties["${i}"]["height"]);
              }
              if(current_tileset.properties["${i}"].containsKey("rotation"))
              {
                toAdd.rotation_ = int.parse(current_tileset.properties["${i}"]["rotation"]);
              }
              ret.add(toAdd);
            }
          }
        }
      }
    }

    return ret;
  }

  List<ModelInstance> readModelData(List<ModelDescription> model_descriptions, Map layer, Tileset current_tileset, Vector2 size)
  {
    List<ModelInstance> model_data = new List<ModelInstance>();

    if (layer.containsKey("data"))
    {
      List<int> data = layer["data"];

      for (int i = 0; i < size.x; i++)
      {
        for (int j = 0; j < size.y; j++)
        {
          int texture = data[(i + j*size.x).floor()] - current_tileset.first_gid;
          if (texture >= 0)
          {
            ModelInstance model = new ModelInstance();
            model.position_ = new Vector2(i*1.0,size.y - j*1.0);
            model.description_ = model_descriptions[texture];
            model_data.add(model);
          }
        }
      }
    }

    return model_data;
  }

  List<BehaviourDescription> readBehaviourData(Map layer, Tileset current_tileset, Vector2 size, List<ModelDescription> model_descriptions)
  {
    List<BehaviourDescription> ret = new List<BehaviourDescription>();
    if (layer.containsKey("data"))
    {
      List<int> data = layer["data"];
      List<String> behaviour_names = new List<String>();
      List<String> model_paths = new List<String>();

      if (current_tileset.name == "behaviours_layer")
      {
        for (int i = 0; i < current_tileset.properties.length; i++)
        {
          String new_name = current_tileset.properties["${i}"]["type"];
          String model_path = current_tileset.properties["${i}"]["path"];
          behaviour_names.add(new_name);
          model_paths.add(model_path);
        }
        for (int i = 0; i < size.x; i++)
        {
          for (int j = 0; j < size.y; j++)
          {
            int id = data[(i + j*size.x).floor()] - current_tileset.first_gid;
            if (id >= 0)
            {
              BehaviourDescription desc = new BehaviourDescription();
              desc.position_ = new Vector2(i*1.0, size.y - j*1.0);
              desc.model_path_ = model_paths[id];
              desc.behaviour_type_ = behaviour_names[id];
              desc.properties_ = new Map();
              ret.add(desc);
            }
          }
        }
      }
    }
    return ret;
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
    List<PortalDescription> portals = new List<PortalDescription>();

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

    List<ModelDescription> model_descriptions = readModelDescriptions(parsed_tilesets);
    List<List<int>> heights = readHeightData(layers, parsed_tilesets, size);
    List<ModelInstance> models = new List<ModelInstance>();
    List<BehaviourDescription> behaviours;

    for (Map layer in layers)
    {
      if (layer.containsKey("data"))
      {
        List<int> data = layer["data"];

        Tileset current_tileset = getTileset(parsed_tilesets, layer);

        if (current_tileset.name == "heights_layer")
        {

        }
        else if (current_tileset.name == "behaviours_layer")
        {
          behaviours = readBehaviourData(layer, current_tileset, size, model_descriptions);
        }
        else if (current_tileset.name == "models_layer")
        {
          models.addAll(readModelData(model_descriptions, layer, current_tileset, size));
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
        if (layer.containsKey("objects"))
        {
          for (Map object in layer["objects"])
          {
            if (object.containsKey("polyline"))
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
                PortalDescription current_portal = new PortalDescription();
                current_portal.map_name_ = properties["map"];
                if (properties.containsKey("hide"))
                {
                  current_portal.map_hide_.add(properties["hide"]);
                }
                if(properties.containsKey("show"))
                {
                  current_portal.map_show_.add(properties["show"]);
                }
                current_portal.points_ = points;
                portals.add(current_portal);
              }
              else
              {
                paths[name] = new Path(name, points);
              }
            }
            else if (object.containsKey("gid"))
            {
              int gid = object["gid"];
              Tileset tileset = getTileTileset(parsed_tilesets, gid);
              gid -= tileset.first_gid;
              BehaviourDescription desc = new BehaviourDescription();
              double x = object["x"] / object ["width"];
              double y = object["y"] / object ["height"] - 0.5;
              desc.position_ = new Vector2(x.round() * 1.0, size.y - (y.round() - 1.0) * 1.0);
              desc.model_path_ = tileset.properties["$gid"]["path"];
              desc.behaviour_type_ = tileset.properties["$gid"]["type"];
              desc.properties_ = object["properties"];
              desc.name_ = object["name"];
              behaviours.add(desc);
            }
          }
        }
      }
    }

    return new LevelData(ret_terrain, models, model_descriptions, behaviours, heights, paths, portals, offset);
  }
}
