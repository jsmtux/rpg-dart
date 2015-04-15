library level_data;

import 'dart:async';

import 'package:vector_math/vector_math.dart';

import "square_terrain.dart";
import 'game_area.dart';
import 'drawable_factory.dart';
import 'base_geometry.dart';
import 'drawable.dart';
import 'model_importer.dart';
import 'behaviour/terrain_behaviour.dart';
import 'behaviour/terrain_element_behaviour.dart';
import 'path.dart';
import 'portal.dart';
import 'game_state.dart';
import 'sprite_importer.dart';

class PortalDescription
{
  String map_name_;
  List<Vector2> points_ = new List<Vector2>();
  List<String> map_hide_ = new List<String>();
  List<String> map_show_ = new List<String>();
}

class LevelData
{
  List<SquareTerrain> terrain_list_;
  List<String> models_ = new List<String>();
  List<double> model_heights_ = new List<double>();
  List<Vector3> model_info_ = new List<Vector3>();
  Map<String, Path> paths_ = new Map<String, Path>();
  List<List<int>> heights_;
  Vector3 offset_;
  List<PortalDescription> portals_;

  Map<String,BaseGeometry> models_geometry_ = new Map<String, BaseGeometry>();

  LevelData(this.terrain_list_, this.models_, this.model_heights_, this.model_info_, this.heights_, this.paths_, this.portals_, this.offset_);

  Future<TerrainBehaviour> AddToGameState(GameArea area, GameState state, SpriteLoader loader)
  {
    Completer completer = new Completer();
    TerrainBehaviour behaviour_t = new TerrainBehaviour(heights_, offset_);
    area.terrain_ = behaviour_t;

    double height = 0.0;
    for (SquareTerrain sq in terrain_list_)
    {
      BaseGeometry terrain_geom = sq.calculateBaseGeometry(height);
      height += 0.005;

      Drawable terrain_drawable = loader.drawable_factory_.createTexturedDrawable(terrain_geom);
      area.addElement(terrain_drawable, behaviour_t);
      Quaternion rot = new Quaternion.identity();
      //rot.setAxisAngle(new Vector3(1.0, 0.0, 0.0 ), -60 * (math.PI / 180));
      terrain_drawable.Rotate(rot);
      terrain_drawable.setPosition(offset_);
    }

    if (paths_ != null)
    {
      area.paths_.addAll(paths_);
    }

    for (PortalDescription portal in portals_)
    {
      Portal toAdd = new Portal(portal.map_name_, state);
      toAdd.areas_hide_ = portal.map_hide_;
      toAdd.areas_show_ = portal.map_show_;
      for (Vector2 pos in portal.points_)
      {
        pos.x += offset_.x;
        pos.y += offset_.y;
      }
      behaviour_t.addPortal(toAdd, portal.points_);
    }

    if (models_ != null)
    {
      ModelImporter importer = new ModelImporter();
      for (String path in models_)
      {
        importer.RequestFile(path).then((List<BaseGeometry> model) => checkFinished(area, model, path, completer, loader, behaviour_t));
      }
    }
    else
    {
      completer.complete(behaviour_t);
    }

    return completer.future;
  }

  void checkFinished(GameArea area, List<BaseGeometry> model, String path, Completer completer, SpriteLoader loader, TerrainBehaviour behaviour_t)
  {
    models_geometry_[path] = model[0];
    if (models_.length == models_geometry_.length)
    {
      processFinished(area, completer, loader, behaviour_t);
    }
  }

  void processFinished(GameArea area, Completer completer, SpriteLoader loader, TerrainBehaviour behaviour_t)
  {
    loader.addModels(models_geometry_);
    for (Vector3 info in model_info_)
    {
      double x = info.x + offset_.x;
      double y = info.y + offset_.y;
      int model = info.z.floor();
      Drawable toAdd = loader.drawable_factory_.createTexturedDrawable(models_geometry_[models_[model]]);
      area.addElement(toAdd , new Tile3dBehaviour(x, y, model_heights_[model], behaviour_t));
    }
    completer.complete(behaviour_t);
  }
}